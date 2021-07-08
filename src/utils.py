import pandas as pd
import numpy as np
import pickle
from sklearn import metrics


# Encode
def one_hot(df, cols):
    """
    @param df pandas DataFrame
    @param cols a list of columns to encode 
    @return a DataFrame with one-hot encoding
    """
    new_cols = []
    for each in cols:
        dummies = pd.get_dummies(df[each], prefix=each, drop_first=False)
        df = pd.concat([df, dummies], axis=1)
        for col in dummies.columns:
            new_cols.append(col)
    return df, new_cols

# Evaluation metrics for regression model
def evaluate_model(true, predicted):  
    mae = metrics.mean_absolute_error(true, predicted)
    mse = metrics.mean_squared_error(true, predicted)
    rmse = np.sqrt(metrics.mean_squared_error(true, predicted))
    mpd = metrics.mean_poisson_deviance(true, predicted)
    r2 = metrics.r2_score(true, predicted)
    print('MAE:', mae)
    print('MSE:', mse)
    print('RMSE:', rmse)
    print('MPD:', mpd)
    print("R2:", r2)
    print('__________________________________')
    return mae, mse, rmse, mpd, r2 

# Saving model 
def save_model(model, name="model"):
    pickle.dump(model, open(f"../bin/{name}", "wb"))