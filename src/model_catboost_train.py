# Basic 
import sys
import json

# Warning problems in notebook
import warnings
warnings.filterwarnings('ignore')

# Math
import numpy as np
import scipy as sp
import pandas as pd

# Profiling process
from tqdm import tqdm

# Statistics
from statsmodels.stats.outliers_influence import variance_inflation_factor

# Metrics
from sklearn import metrics

# Preprocessing
from sklearn.preprocessing import OneHotEncoder, LabelEncoder
from sklearn.preprocessing import StandardScaler, MinMaxScaler

# Learning Helper | Modelling
from sklearn.model_selection import train_test_split
from catboost import CatBoostRegressor

# Utils
from utils import one_hot, evaluate_model, save_model

if __name__ == "__main__":
    # === Load data ===
    ## EDIT THIS CODE
    # =====================
    filename = "../data/processed/dataset-supervised-processed.pkl"
    # =====================
    target = "wd_actual_delivery_interval"
    df = pd.read_pickle(filename)
    df = df.dropna()

    # Preprocess before model
    cat_num_features =['order_quarter', 'order_is_weekend',
                               'order_approved_quarter', 'order_approved_is_weekend',
                               'pickup_limit_quarter', 'pickup_limit_is_weekend', "is_same_area"]
    cat_str_features = ["order_daytime", "order_approved_daytime"]

    for col in tqdm(cat_num_features):
        df[col] = df[col].astype(int)

    # Data Preparation
    target = "wd_actual_delivery_interval"
    detector = "wd_estimated_delivery_interval"
    
    X = df.drop([target], axis = 1)
    y = df[target]

    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=123, test_size=0.2)

    baseline_pred = X_test[detector].values

    # === Removing the detector cols ===
    X_train = X_train.drop([detector], axis = 1)
    X_test = X_test.drop([detector], axis = 1)
    
    train = X_train.copy()
    train[target] = y_train.values
    val = X_test.copy()
    val[target] = y_test.values
    
    # Baseline
    print("Baseline (Naive Approach): ")
    mae,mse,rmse,mpd,r2 = evaluate_model(y_test, baseline_pred)
    results_df = pd.DataFrame(data=[["Baseline (Naive)", mae, mse, rmse, mpd,r2]], 
                          columns=['Model', 'MAE', 'MSE', 'RMSE', "MPD", "R2"])
    
    # Modelling
    ignored_features = []
    model = CatBoostRegressor(objective='Poisson', loss_function = 'RMSE',eval_metric = 'RMSE', cat_features=cat_num_features + cat_str_features, iterations=10000)
    model.fit(X_train, y_train, eval_set = (X_test, y_test), use_best_model = True,plot = True, verbose=200, early_stopping_rounds=500)
    
#     save_model(model, "catboost-regressor")
    
    pred = model.predict(X_test)
    train_pred = model.predict(X_train)
    
    print('Train set evaluation:\n_____________________________________')
    _, _, _, _, _ = evaluate_model(y_train, train_pred)
    print('Train set evaluation:\n_____________________________________')
    mae,mse,rmse,mpd,r2 = evaluate_model(y_test, pred)
    
    results_df_catboost = pd.DataFrame(data=[["Catboost Regression",  mae, mse, rmse, mpd,r2]], 
                          columns=['Model', 'MAE', 'MSE', 'RMSE', "MPD", "R2"])

    results_df = results_df.append(results_df_catboost, ignore_index=True)
    print(results_df)