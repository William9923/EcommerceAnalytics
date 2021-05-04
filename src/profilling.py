import sys
import numpy as np
import scipy as sp
import pandas as pd

import psycopg2
import pandas as pd
from sqlalchemy import create_engine

from tqdm import tqdm

# Profiling
import sweetviz as sv
from dataprep.eda import create_report

# Utilities
from util import load_config

# Global configuration
config = load_config("../config.json")
DBNAME = config.get("DBNAME")
HOSTNAME = config.get("HOSTNAME")
USER = config.get("USER")
PASS = config.get("PASS")
SCHEMA = config.get("SCHEMA")

# Reporting utilities
def sweetviz_profilling(df, filename):
    advert_report = sv.analyze(df)
    advert_report.show_html(filename + ".html")

def dataprep_profilling(df, title, filename, path):
    report = create_report(df, title=title)
    report.save(filename=filename, to=path)


if __name__ == '__main__':
    # Create an engine instance
    alchemyEngine = create_engine(
        f'postgresql+psycopg2://{USER}:{PASS}@{HOSTNAME}/{DBNAME}', pool_recycle=3600)

    # Connect to PostgreSQL server
    conn = alchemyEngine.connect()

    schema = SCHEMA

    date = pd.read_sql_table("dim_date", conn, schema=schema)
    time = pd.read_sql_table("dim_time", conn, schema=schema)
    user = pd.read_sql_table("dim_user", conn, schema=schema)
    product = pd.read_sql_table("dim_product", conn, schema=schema)
    seller = pd.read_sql_table("dim_seller", conn, schema=schema)
    feedback = pd.read_sql_table("dim_feedback", conn, schema=schema)
    fct_order_item = pd.read_sql_table("fct_order_items", conn, schema=schema)

    dataset = [date, time, user, product, seller, feedback, fct_order_item]
    filenames = ["DateDimension", "TimeDimension", "UserDimension", "ProductDimension",
                 "SellerDimension", "FeedbackDimension", "OrderFact"]

    folder = "../reports/"
    
    # Profiling
    dataprep_profilling(user, "UserDimension", "User" + "_prep", folder)
    dataprep_profilling(product, "ProductDimension", "Product" + "_prep", folder)
    dataprep_profilling(seller, "SellerDimension", "Seller" + "_prep", folder)
    dataprep_profilling(feedback, "FeedbackDimension" , "Feedback" + "_prep", folder)

    sweetviz_profilling(fct_order_item, folder + "OrderFact" + "_sf")
    conn.close()

    alchemyEngine.dispose()
