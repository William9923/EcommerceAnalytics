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


if __name__ == '__main__':
    # Create an engine instance
    alchemyEngine = create_engine(
        f'postgresql+psycopg2://{USER}:{PASS}@{HOSTNAME}/{DBNAME}', pool_recycle=3600)

    # Connect to PostgreSQL server
    conn = alchemyEngine.connect()

    schema = "staging"

    date = pd.read_sql_table("dim_date", conn, schema=schema)
    time = pd.read_sql_table("dim_time", conn, schema=schema)
    user = pd.read_sql_table("dim_user", conn, schema=schema)
    product = pd.read_sql_table("dim_product", conn, schema=schema)
    seller = pd.read_sql_table("dim_seller", conn, schema=schema)
    feedback = pd.read_sql_table("dim_feedback", conn, schema=schema)
    fct_order_item = pd.read_sql_table("fct_order_items", conn, schema=schema)

    dataset = [date, time, user, product, seller, feedback, fct_order_item]
    filenames = ["DateDimension", "TimeDimension", "ProductDimension",
                 "SellerDimension", "FeedbackDimension", "OrderFact"]

    folder = "../reports/"

    for filename, data in tqdm(zip(filenames, dataset)):
        sweetviz_profilling(data, folder + filename + "_sp")

    conn.close()

    alchemyEngine.dispose()