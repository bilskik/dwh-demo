import os
import shutil
import kagglehub
import pandas as pd
from sqlalchemy import create_engine
from snowflake.sqlalchemy import URL

# Konfiguracja Snowflake
SF_CONFIG = {
    "user": "",
    "password": "",
    "account": "",
    "warehouse": "COMPUTE_WH",
    "database": "ecommerce_db_demo",
    "schema": "ECOMMERCE_DEMO",
    "role": "ACCOUNTADMIN"
}

def do_magic_trick(cleanup=False):
    print("Downloading dataset from Kaggle...")
    download_path = kagglehub.dataset_download("olistbr/brazilian-ecommerce")

    # Tworzenie Connection String dla Snowflake
    engine = create_engine(URL(
        account=SF_CONFIG['account'],
        user=SF_CONFIG['user'],
        password=SF_CONFIG['password'],
        database=SF_CONFIG['database'],
        schema=SF_CONFIG['schema'],
        warehouse=SF_CONFIG['warehouse'],
        role=SF_CONFIG['role']
    ))
    
    files = [f for f in os.listdir(download_path) if f.endswith('.csv')]

    try: 
        for file_name in files:
            file_path = os.path.join(download_path, file_name)
            table_name = file_name.replace('.csv', '').replace("olist_","").replace("_dataset", "").upper()
            
            print(f"Importing {file_name} into Snowflake table '{table_name}'...")
            
            df = pd.read_csv(file_path)
            
            # Konwersja dat
            date_cols = [col for col in df.columns if 'timestamp' in col or 'date' in col]
            for col in date_cols:
                df[col] = pd.to_datetime(df[col], errors='coerce')

            df.columns = [col.upper() for col in df.columns]
            
            df.to_sql(
                name=table_name.lower(),
                con=engine, 
                if_exists='replace',
                index=False, 
                chunksize=10000 
            )
            print(f"Table '{table_name}' uploaded successfully.")

    finally:
        if os.path.exists(download_path) and cleanup:
            print(f"Cleaning up: Removing {download_path}...")
            shutil.rmtree(download_path)
            print("Cleanup complete.")

    print("\nSuccess! All data imported into Snowflake.")

if __name__ == "__main__":
    do_magic_trick()