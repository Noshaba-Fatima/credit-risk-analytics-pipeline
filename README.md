# Credit Risk Data Pipeline & Analytics Dashboard

An end-to-end data engineering and business intelligence project for analyzing credit card default risk. This repository automates the ingestion and cleaning of 30,000 client financial records from Kaggle into a relational MySQL database, runs advanced SQL queries for behavioral risk segmentation, and powers an interactive Power BI dashboard for executive reporting.

## Architecture

```text
Kaggle API (UCI Credit Card Dataset)
        │
        ▼
Python ETL Pipeline (pipeline.py)
  • Programmatic download & extraction
  • Schema normalization, null filtering & strict float casting
  • Environment-based credential management (.env)
        │
        ▼
MySQL Database (credit_risk_db.credit_risk_portfolio)
        │
        ▼
SQL Analytics Layer (queries.sql)
  • CTEs, CASE logic & Window Functions (NTILE)
  • Behavioral debt trajectory & risk tiering
        │
        ▼
Power BI Dashboard (Credit_Risk_Dashboard.pbix)
  • Live MySQL connection, dynamic DAX measures & cross-filtering
```

## Dashboard Preview

![Credit Risk Dashboard](dashboard_final.png)

## Key Features

- **Automated ETL Pipeline (`pipeline.py`):** Authenticates programmatically with the Kaggle API to download and unzip the UCI Default of Credit Card Clients dataset (30,000 rows). Standardizes column names for SQL compatibility, enforces strict floating-point casting on monetary columns, drops incomplete demographic records, and loads the cleaned table into MySQL via SQLAlchemy and PyMySQL.
- **Secure Credential Management:** Keeps Kaggle API keys and MySQL passwords out of source control using `python-dotenv` (`.env`) and `.gitignore`.
- **Advanced SQL Risk Segmentation (`queries.sql`):** Uses Common Table Expressions (CTEs), `CASE` statements, and `NTILE` window functions to segment borrowers by credit utilization and repayment history—identifying high-risk patterns such as the **Minimum Payment Trap**.
- **Executive BI Reporting (`Credit_Risk_Dashboard.pbix`):** Connects directly to MySQL with dynamic DAX measures to track portfolio exposure, default rates, and demographic risk profiles.

## Tech Stack

| Layer | Tools & Technologies |
| :--- | :--- |
| **Ingestion & ETL** | Python, Pandas, SQLAlchemy, PyMySQL, Kaggle API, python-dotenv |
| **Database** | MySQL, MySQL Workbench |
| **Analytics** | SQL (CTEs, Window Functions, `NTILE`, `CASE`) |
| **Visualization** | Power BI Desktop, DAX |

## Repository Structure

```text
├── pipeline.py                  # Automated Kaggle-to-MySQL ETL script
├── queries.sql                  # Risk segmentation & behavioral SQL queries
├── Credit_Risk_Dashboard.pbix   # Interactive Power BI report
├── dashboard_final.png          # Dashboard preview screenshot
├── requirements.txt             # Python dependencies
├── .gitignore                   # Excludes .env, virtual environments, and raw data
└── README.md
```

## Setup & Usage

### Prerequisites
- Python 3.9+
- MySQL Server & MySQL Workbench
- Power BI Desktop
- A Kaggle account with an active API key

### 1. Clone the Repository
```bash
git clone [https://github.com/Noshaba-Fatima/credit-risk-analytics.git](https://github.com/Noshaba-Fatima/credit-risk-analytics.git)
cd credit-risk-analytics
```

### 2. Install Dependencies
```bash
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 3. Configure Environment Variables
Create a `.env` file in the root directory:
```env
KAGGLE_USERNAME=your_kaggle_username
KAGGLE_KEY=your_kaggle_api_key

MYSQL_USER=root
MYSQL_PASSWORD=your_mysql_password
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DB=credit_risk_db
```
*(Create the `credit_risk_db` database in MySQL Workbench before running the script.)*

### 4. Run the Pipeline & Analytics
1. Run the ETL script to download the dataset and populate MySQL:
   ```bash
   python pipeline.py
   ```
2. Open `queries.sql` in **MySQL Workbench** and execute the queries against `credit_risk_db`.
3. Open `Credit_Risk_Dashboard.pbix` in **Power BI Desktop** and click **Refresh** to sync with your local MySQL database.