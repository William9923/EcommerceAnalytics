# ECommerce Project

#### Status: Active
#### Progress Report 
Progress report akan dilakukan setiap 2 minggu, dengan rincian sebagai berikut : 
* Week 1 - 2 (9 Feb 2021 - 23 Feb 2021)
- [x] Melakukan inisialisasi struktur proyek terhadap github
- [x] Eksplorasi terkait tools pada dbeaver 
- [x] Eksplorasi data untuk menemukan relasi pada dataset
- [x] Mencari cara untuk memudahkan sistem Import/Export dari .csv ke database
- [x] Membuat skema ER Diagram untul OLTP database

* Week 3 - 4 (23 Feb 2021 - 9 Mar 2021)
- [x] Melakukan revisi terhadap desain OLTP database sesuai dengan hasil mentoring
- [x] Eksplorasi data warehouse
- [x] Mendesain struktur data warehouse
- [x] Menyiapkan staging area untuk data warehouse
- [x] Preparing schema untuk data warehouse & datamart (+business question)
- [x] Eksplorasi & Pembuatan Pipeline ETL

* Week 5 - 6 (9 Mar 2021 - 23 Mar 2021)
- [x] Memperbaiki struktur pipeline (menambah 1 layer untuk memasukkan data dari csv langsung ke database)
- [x] Mengubah pipeline loading data warehouse (dari staging db --> datawarehouse)
- [x] Mengecek struktur data warehouse agar sesuai dengan kebutuhan bisnis (business question)
- [x] Menyusun business question yang tepat 

* Week 7 - 8 (23 Mar 2021 - 6 Apr 2021)
- [x] Melakukan quality checking terhadap Pipeline ETL
- [x] Menerapkan integrity dan referential constraint pada warehouse
- [x] Memperbaiki pipeline yang salah kemarin (ada beberapa data yang lost dari pengecekan)
- [x] Pembuatan datamart sesuai dengan pertanyaan bisnis yang telah diusulkan
- [x] Eksplorasi platform data analysis yang tersedia

* Week 9 - 10 (6 Apr 2021 - 21 Apr 2021)
- [x] HOTFIX : Redesign Payment Dimension Table (saran kak Hans)
- [x] Memulai EDA untuk mencari business question yang menarik pada data yang ada

* Week 11 - 12 (21 Apr 2021 - 5 May 2021)
- [x] Menyusun datamart
- [x] Menyusun business question (60%)
- [x] Eksplorasi ecommerce terkait business question

* Week 13 - 14 (5 May 2021 - 26 May 2021)( + 1 week holiday)
- [x] Menyusun business question (100%)
- [x] Basic EDA for business question
- [x] Complete Background for business question
- [x] Answer + Visualization + explanation for business qurstion

* Week 15 - 16 (26 May 2021 - 9 June 2021)
- [x] Finalize Business Question Analysis
- [x] Create reporting docs -> only dashboard, full report not done
- [x] Setup for supervised learning (machine learning opportunities)
- [x] Define metric for supervised learning

* Week 17 - 18 (9 June 2021 - 23 June 2021)
* [x] EDA dataset for supervised machine learning opportunities
- [x] Create baseline for supervised machine learning opportunities
- [x] Evaluate baseline 
- [ ] Planning for more sophisticated approach for supervised problem (using more complicated model to capture information from data)

* Week 19 - 20 (23 June 2021 - 7 July 2021)
- [x] Feature engineering from original data to create meaningful feature
- [x] Reporting for baseline + some f.eng approach on machine learning opportunities
- [ ] Refactor code for training model

* Week 21 - 22 (7 July 2021 - 21 July 2021)
- [x] Done research for unsupervised learning
- [x] Done setup + prepare for unsupervised learning (data constructed, still deep diving about unsupervised learning)
- [x] Done revision for business problem visualization (from ci gaby)
- [x] Done revision for machine learning opportunities (from ko Johan)
- [ ] Refactoring notebook structure for machine learning opportunities

Lebih lengkapnya dapat mengarah ke link [wiki](https://github.com/William9923/future-data-ecommerce/wiki) sebagai berikut

#### Documentation & Deliveribles -> see [drive](https://drive.google.com/drive/folders/1EhdzxzMnBAIJyZU9aXpXrXs58gSnTMKU?usp=sharing) 

## Overview
Proyek ini digunakan untuk menjawab pertanyaan - pertanyaan bisnis serta menghasilkan suatu solusi inovatif yang menarik melalui penerapan statistik, visualisasi data yang baik dan mudah dilihat serta menemukan permasalahan - permasalahan yang dapat diselesaikan dengan bantuan supervised dan unsupervised learning guna memperoleh insight baru dalam dunia E-commerce.

## Data Warehouse Schema
[Link](https://dbdiagram.io/d/604272d1fcdcb6230b22cecc)

### Methods Used (in the future)
* Inferential Statistics
* Machine Learning
* Data Visualization
* Supervised Modeling
* Unsupervised Modeling

### Technologies
* Python
* Pandas, jupyter

### Project Structure
root
├───models           <- Trained and serialized models, model predictions, or model summaries
├───notebooks        <- Jupyter notebooks.
├───scripts          <- Source code for use in this project.
## Usage

### Author
* [William](https://william9923.github.io/)
