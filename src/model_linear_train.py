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
from sklearn.linear_model import LinearRegression, PoissonRegressor, RANSACRegressor

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
    
    # Data Preparation
    df['is_same_area'] = df['is_same_area'].astype('int')
    to_drop = ["wd_estimated_delivery_interval"]
    numerical = ["log_aov", "log_shipping_cost", "wd_pickup_limit_interval", "log_package_weight_g", "product_weight_g_per_item", "cbrt_original_distance"]
    categorical = ["is_same_area"]

    df_model = df[numerical + categorical + [target] + to_drop]
    scaler = StandardScaler()
    df_model[numerical] = scaler.fit_transform(df_model[numerical])
    df_model, _ = one_hot(df_model, categorical)
    df_model = df_model.drop(categorical, axis = 1)
    
    X = df_model.drop([target], axis = 1)
    y = df_model[target]

    detector="wd_estimated_delivery_interval"

    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=123, test_size=0.2)

    baseline_pred = X_test[detector].values

    # === Removing the detector cols ===
    X_train = X_train.drop([detector], axis = 1)
    X_test = X_test.drop([detector], axis = 1)
    
    # === Evaluate baseline ===
    print("Baseline (Naive Approach): ")
    mae,mse,rmse,mpd,r2 = evaluate_model(y_test, baseline_pred)
    results_df = pd.DataFrame(data=[["Baseline (Naive)", mae, mse, rmse, mpd,r2]], 
                          columns=['Model', 'MAE', 'MSE', 'RMSE', "MPD", "R2"])
    
    # === Train Linear Model ===
    lin_reg =  PoissonRegressor(alpha=1e-12, max_iter=1000)
    lin_reg.fit(X_train,y_train)
    save_model(lin_reg, "poisson-regression")
    test_pred = lin_reg.predict(X_test)
    train_pred = lin_reg.predict(X_train)

    print("Linear Regression (Poisson): ")
    print('Test set evaluation:\n_____________________________________')
    mae, mse, rmse, mpd,r2 = evaluate_model(y_test, test_pred)
    
    results_df_linreg = pd.DataFrame(data=[["Poisson Regression",  mae, mse, rmse, mpd,r2]], 
                          columns=['Model', 'MAE', 'MSE', 'RMSE', "MPD", "R2"])

    results_df = results_df.append(results_df_linreg, ignore_index=True)
    
    robust_model = RANSACRegressor(base_estimator=PoissonRegressor(alpha=1e-12, max_iter=300), max_trials=100, random_state=123)
    robust_model.fit(X_train,y_train)
    save_model(robust_model, "robust-regression")
    test_pred = robust_model.predict(X_test)
    train_pred = robust_model.predict(X_train)

    print("Robust Regression : ")
    print('Test set evaluation:\n_____________________________________')
    mae, mse, rmse, mpd,r2 = evaluate_model(y_test, test_pred)
    
    # === Appending result to current data
    results_df_robreg = pd.DataFrame(data=[["Robust Regression", mae, mse, rmse, mpd, r2]], 
                              columns=['Model', 'MAE', 'MSE', 'RMSE', "MPD", "R2"])

    results_df = results_df.append(results_df_robreg, ignore_index=True)
    print(results_df)