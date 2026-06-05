# 🏦 End-to-End Credit Risk Data Pipeline & Analytics Dashboard

## 📌 Project Overview
This project demonstrates a complete Data Engineering and Business Intelligence workflow. I built an automated ETL pipeline to ingest credit default data, engineered a relational database in MySQL, wrote advanced SQL analytics to uncover behavioral risk factors, and developed a fully interactive Power BI dashboard for executive reporting.

## 🛠️ Tech Stack & Architecture
* **Language:** Python (Pandas, SQLAlchemy)
* **Database:** MySQL (Local Server)
* **Analytics:** Advanced SQL (CTEs, Window Functions, Case Statements)
* **Visualization:** Power BI Desktop

## 📊 Dashboard Preview
*(The image below displays the interactive dashboard connected live to the MySQL database)*

![Credit Risk Dashboard](dashboard_final.png)

## ⚙️ Key Technical Achievements
1. **Automated Data Ingestion:** Wrote a Python script (`pipeline.py`) to clean, format, and load 30,000 raw financial records directly into a MySQL database.
2. **Advanced SQL Risk Segmentation:** Authored highly optimized queries (`queries.sql`) utilizing Window Functions (`NTILE`) and Complex CTEs to identify critical debt trajectories, such as the "Minimum Payment Trap."
3. **Executive BI Reporting:** Built a fully cross-filtered Power BI dashboard featuring dynamic DAX measures to track real-time portfolio exposure and demographic default risks.

## 🚀 How to Run Locally
1. Clone this repository.
2. Execute `pipeline.py` to build and populate the MySQL database.
3. Run the analytical queries in `queries.sql` via MySQL Workbench.
4. Open `Credit_Risk_Dashboard.pbix` in Power BI and refresh the data connection.
