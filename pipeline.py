import os
from urllib.parse import quote_plus
from dotenv import load_dotenv
import pandas as pd
from sqlalchemy import create_engine

# Load environment variables BEFORE importing KaggleApi
load_dotenv()

from kaggle.api.kaggle_api_extended import KaggleApi

# ---------------------------------------------------------
# 1. VALIDATE ENVIRONMENT VARIABLES
# ---------------------------------------------------------
required_vars = ["KAGGLE_USERNAME", "KAGGLE_KEY", "MYSQL_PASSWORD"]
missing_vars = [var for var in required_vars if not os.getenv(var)]
if missing_vars:
    raise EnvironmentError(f"Missing required environment variables in .env: {', '.join(missing_vars)}")

# ---------------------------------------------------------
# 2. PROGRAMMATIC INGESTION (NATIVE PYTHON API)
# ---------------------------------------------------------
print("Authenticating with Kaggle...")
api = KaggleApi()
api.authenticate()

print("Downloading and extracting credit dataset...")
api.dataset_download_files(
    "uciml/default-of-credit-card-clients-dataset",
    path="data/",
    unzip=True
)
print("Download and extraction complete!")

# ---------------------------------------------------------
# 3. PANDAS DATA ENGINEERING LAYER
# ---------------------------------------------------------
print("Loading data into Pandas for transformation...")
df = pd.read_csv("data/UCI_Credit_Card.csv")

# Lowercase and clean spaces and dots out of column names for seamless SQL mapping
df.columns = df.columns.str.lower().str.replace(" ", "_").str.replace(".", "_", regex=False)

# Rename the target to make it industry-standard
df.rename(columns={"default_payment_next_month": "default_status"}, inplace=True)

# Quality Control: Drop records missing key demographics
df.dropna(subset=["limit_bal", "sex", "education", "marriage", "age"], inplace=True)

# Strict Type Casting: Force money values into floats to avoid rounding bugs
financial_columns = [
    "limit_bal", "bill_amt1", "bill_amt2", "bill_amt3",
    "pay_amt1", "pay_amt2", "pay_amt3"
]
for col in financial_columns:
    df[col] = df[col].astype(float)

print(f"Data transformed successfully! Ingestion matrix shape: {df.shape}")

# ---------------------------------------------------------
# 4. RELATIONAL LOADING (LOCAL MYSQL DATABASE)
# ---------------------------------------------------------
print("Connecting to local MySQL server engine...")

db_user = os.getenv("MYSQL_USER", "root")
db_password = quote_plus(os.getenv("MYSQL_PASSWORD"))
db_host = os.getenv("MYSQL_HOST", "localhost")
db_port = os.getenv("MYSQL_PORT", "3306")
db_name = os.getenv("MYSQL_DB", "credit_risk_db")

engine = create_engine(f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}")

try:
    df.to_sql("credit_risk_portfolio", con=engine, if_exists="replace", index=False)
    print("\nETL PIPELINE SUCCESSFUL!")
    print("Go to MySQL Workbench and refresh—your 'credit_risk_portfolio' table is loaded.")
except Exception as e:
    print(f"\nDatabase stream failed. Debug details: {e}")