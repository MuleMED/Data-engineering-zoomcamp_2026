import pandas as pd
import pyarrow.parquet as pq
from sqlalchemy import create_engine
import time

# Database connection
engine = create_engine('postgresql://postgres:postgres@localhost:5433/ny_taxi')

# Read and process taxi zones data
print("Loading taxi zones data...")
zones_df = pd.read_csv('taxi_zone_lookup.csv')
zones_df.to_sql(name='taxi_zones', con=engine, if_exists='replace', index=False)
print(f"Loaded {len(zones_df)} zones")

# Read and process green taxi trips data
print("Loading green taxi trips data for November 2025...")
try:
    trips_df = pd.read_parquet('green_tripdata_2025-11.parquet')
    print(f"Loaded {len(trips_df)} trips")
    
    # Create table in PostgreSQL
    print("Creating table in PostgreSQL...")
    trips_df.head(n=0).to_sql(name='green_taxi_trips', con=engine, if_exists='replace')

    # Insert data in chunks
    print("Inserting data in chunks...")
    chunk_size = 100000
    for i in range(0, len(trips_df), chunk_size):
        chunk = trips_df[i:i+chunk_size]
        chunk.to_sql(name='green_taxi_trips', con=engine, if_exists='append')
        print(f"Inserted rows {i} to {i+len(chunk)}")
        
    print("Data ingestion complete!")
    
except Exception as e:
    print(f"Error loading data: {e}")
    import traceback
    traceback.print_exc()
