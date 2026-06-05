import os
import pandas as pd
from sqlalchemy import create_engine
from kaggle.api.kaggle_api_extended import KaggleApi

# ---------------------------------------------------------
# 1. KAGGLE AUTHENTICATION
# ---------------------------------------------------------
# CRITICAL: Replace "your_username_here" with your actual Kaggle username
os.environ['KAGGLE_USERNAME'] = "noshabafatima" 
os.environ['KAGGLE_KEY'] = "4c7626531f876115686aff2079fc25e3"

# ---------------------------------------------------------
# 2. PROGRAMMATIC INGESTION (NATIVE PYTHON API)
# ---------------------------------------------------------
print("Authenticating with Kaggle...")
api = KaggleApi()
api.authenticate()

print("Downloading and extracting credit dataset...")
# This single line downloads AND unzips the file automatically into your data folder!
api.dataset_download_files('uciml/default-of-credit-card-clients-dataset', path='data/', unzip=True)
print("Download and extraction complete!")

# ---------------------------------------------------------
# 3. PANDAS DATA ENGINEERING LAYER
# ---------------------------------------------------------
print("Loading data into Pandas for transformation...")

# Read the CSV normally (without skipping the header)
df = pd.read_csv('data/UCI_Credit_Card.csv')

# Lowercase and clean spaces AND dots out of column names for seamless SQL mapping
df.columns = df.columns.str.lower().str.replace(' ', '_').str.replace('.', '_')

# Rename the target to make it industry-standard
df.rename(columns={'default_payment_next_month': 'default_status'}, inplace=True)

# Quality Control: Drop records missing key demographics
df.dropna(subset=['limit_bal', 'sex', 'education', 'marriage', 'age'], inplace=True)

# Strict Type Casting: Force money values into floats to avoid rounding bugs
financial_columns = ['limit_bal', 'bill_amt1', 'bill_amt2', 'bill_amt3', 'pay_amt1', 'pay_amt2', 'pay_amt3']
for col in financial_columns:
    df[col] = df[col].astype(float)

print(f"Data transformed successfully! Ingestion matrix shape: {df.shape}")

# ---------------------------------------------------------
# 4. RELATIONAL LOADING (LOCAL MYSQL DATABASE)
# ---------------------------------------------------------
# ---------------------------------------------------------
# 4. RELATIONAL LOADING (LOCAL MYSQL DATABASE)
# ---------------------------------------------------------
from urllib.parse import quote_plus

print("Connecting to local MySQL server engine...")

# Put your exact MySQL password inside the quotes here (even if it has @ or #)
password = quote_plus("Datascience@25")

# The 'f' at the beginning of the string lets us inject the safely encoded password
engine = create_engine(f'mysql+pymysql://root:{password}@localhost:3306/credit_risk_db')

try:
    # Stream the structured dataframe across your local port to create the database table
    df.to_sql('credit_risk_portfolio', con=engine, if_exists='replace', index=False)
    print("\nETL PIPELINE SUCCESSFUL!")
    print("Go to MySQL Workbench and refresh—your 'credit_risk_portfolio' table is loaded.")
except Exception as e:
    print(f"\nDatabase stream failed. Debug details: {e}")