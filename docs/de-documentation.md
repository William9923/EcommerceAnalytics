# Part 1 : Data Engineering

<div style="text-align:center">
    <img src="../figure/etl-illus.jpg" />
</div>

## Introduction
> Data engineering is a process to provide data in usable formats to the data analytics and data scientists who run queries to perform analytics and applying algorithms against the information for predictive analytics, machine learning and data mining applications.

<!-- Introduction & Usecase of data engineering -->
<div style="text-align:center">
    <img src="../figure/data-engineering.png" />
</div>

Most of the time, data are not in the best shape for analysis. Without data engineering process, we would have to spend more time preparing data analysis to solve complex business problems. Thus, this part (**Part I**) is a process to make the data ready & available for analysis (**Part II**) and modelling (**Part III**)

<!-- Introduction to our project -->
In this part, we were asked to load dataset in `csv` format into Database Server (PostgresSQL).
After that, we need to : 
1. **Identify** : Find the relation between dataset 
2. **Design** : Design OLTP & OLAP to load & analyze data
3. **Execute** : Load data into warehouse using ETL process

<!-- Ending Intro -->
This documentation provide the process & result of pipeline that I create & use for **Part 1**. 💪

<!-- TABLE OF CONTENTS -->
## Table of Contents
* [Prerequisites](#prerequisites)
* [Architecture Diagram](#architecture)
* [Database Diagram](#database)
* [Process](#process)
* [Warehouse Diagram](#data-warehouse)
* [References](#references)

## Prerequisites
First of all, all data used for this project were **given** by our mentor (**primary data**). Dataset consists of 7 `csv` files.

**Dataset :**

No | Filename | Description |
---: | :---: | :--- |
1 | user_dataset.csv | dataset containing details of user
2  | order_dataset.csv | dataset containing information for an order
3 | order_item_dataset.csv | dataset containing information for each product from an order
4 | payment_dataset.csv | dataset containing information from each payment for an order
5 | products_dataset.csv | dataset containing details of product
6 | seller_dataset.csv | dataset containing details of seller
7 | feedback_dataset.csv | dataset containing information from each feedback for an order

For the project environment, please use : 
* [PostgresSQL v10.0](https://www.postgresql.org/about/news/postgresql-10-released-1786/) 
* [Python 3.8+ (pip)](https://www.python.org/)

## Architecture
<div style="text-align:center">
    <h3>Pipeline Simplify</h3>
    <img src="../figure/de-pipeline.jpg" />
</div>

## Database
<div style="text-align:center">
    <h3>Transactional Database</h3>
    <img src="../figure/OLTP Bliseries.vpd.png" />
</div>

Before we talk about the how we would create 

## Process
### Finding relationship
### Modelling Warehouse
### ETL (Extract → Transform → Load)

## Data Warehouse
<div style="text-align:center">
    <h3>Data Warehouse</h3>
    <img src="../figure/OLAP Bliseries.png" />
</div>

So, from the pipeline that we create (explained from previous section), this are the schema for the data warehouse that we will use for **Part II** & **Part III**. 

Explanation on dimension table

Explanation on fact tables

## References
- [Quick Guide for Data Engineering](https://realpython.com/python-data-engineer/)
- [Importance of Data Engineering](https://www.analyticsvidhya.com/blog/2021/06/data-engineering-concepts-and-importance/)






