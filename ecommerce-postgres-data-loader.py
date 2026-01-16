import os
import shutil
import kagglehub
import pandas as pd
from sqlalchemy import create_engine

DB_CONFIG = {
    "user": "postgres",
    "password": "password",
    "host": "localhost",
    "port": "5432",
    "database": "olist_db"
}

def download_only():
    print("Downloading dataset from Kaggle...")
    kagglehub.dataset_download("olistbr/brazilian-ecommerce")


def do_magic_trick(cleanup=False):
    print("Downloading dataset from Kaggle...")
    download_path = kagglehub.dataset_download("olistbr/brazilian-ecommerce") # skips download when it's already present on machine

    connection_string = f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
    engine = create_engine(connection_string)
    files = [f for f in os.listdir(download_path) if f.endswith('.csv')]

    try: 
        for file_name in files:
            file_path = os.path.join(download_path, file_name)
            table_name = file_name.replace('.csv', '').replace("olist_","").replace("_dataset", "")
            print(f"Importing {file_name} into table '{table_name}'...")
            
            df = pd.read_csv(file_path)
            
            date_cols = [col for col in df.columns if 'timestamp' in col or 'date' in col]
            for col in date_cols:
                df[col] = pd.to_datetime(df[col], errors='coerce')

            df.to_sql(
                name=table_name, 
                con=engine, 
                if_exists='replace',
                index=False, 
                chunksize=10000, 
                method='multi'
            )
    finally:
        if os.path.exists(download_path) and cleanup:
            print(f"Cleaning up: Removing {download_path}...")
            shutil.rmtree(download_path)
            print("Cleanup complete.")

    print("\nSuccess! All data imported into PostgreSQL.")


do_magic_trick()