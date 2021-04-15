import sys
import numpy as np
import scipy as sp
import pandas as pd
# import matplotlib.pyplot as plt

import psycopg2
import pandas as pd
from sqlalchemy import create_engine

from tqdm import tqdm

# Profiling
import sweetviz as sv

# Global configuration
DBNAME = "ecommerce"
HOSTNAME = "localhost"
USER = "postgres"
PASS = "9923"


def sweetviz_profilling(df, filename):
    advert_report = sv.analyze(df)
    advert_report.show_html(filename + ".html")


def pandas_profilling(df, filename):
    profile = ProfileReport(
        df, title=f"{filename} Profiling Report", explorative=True)
    profile.to_file(filename + ".html")


if __name__ == '__main__':
    # Create an engine instance
    alchemyEngine = create_engine(
        f'postgresql+psycopg2://{USER}:{PASS}@{HOSTNAME}/{DBNAME}', pool_recycle=3600)

    # Connect to PostgreSQL server
    conn = alchemyEngine.connect()

    schema = "warehouse"
    date = pd.read_sql_table("dim_date", conn, schema=schema)
    user = pd.read_sql_table("dim_user", conn, schema=schema)
    product = pd.read_sql_table("dim_product", conn, schema=schema)
    seller = pd.read_sql_table("dim_seller", conn, schema=schema)
    feedback = pd.read_sql_table("dim_feedback", conn, schema=schema)
    payment = pd.read_sql_table("dim_payment", conn, schema=schema)
    fct_order_item = pd.read_sql_table("fct_order_items", conn, schema=schema)

    dataset = [date, user, product, seller, feedback, payment, fct_order_item]
    filenames = ["DateDimension", "UserDimension", "ProductDimension",
                 "SellerDimension", "FeedbackDimension", "PaymentDimension", "OrderFact"]

    folder = "../reports/"

    for filename, data in tqdm(zip(filenames, dataset)):
        sweetviz_profilling(data, folder + filename + "_sp")

    conn.close()

    alchemyEngine.dispose()
