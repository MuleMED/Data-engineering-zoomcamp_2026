# Data Engineering Zoomcamp 2026 — Module 1 Homework

This README contains all instructions, commands, and SQL queries required to complete Homework 1.

---

## Prerequisites

### Download Required Datasets

```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

---

## Docker Setup

### Start Services

```bash
docker-compose up -d
```

### Verify Connection

```bash
docker exec -it postgres psql -U postgres -d ny_taxi -c "SELECT 1;"
```

---

## Database Setup

### Create Tables

Connect to Postgres:

```bash
docker exec -it postgres psql -U postgres -d ny_taxi
```

Then execute the following SQL:

```sql
CREATE TABLE IF NOT EXISTS green_taxi_trips (
    VendorID INTEGER,
    lpep_pickup_datetime TIMESTAMP,
    lpep_dropoff_datetime TIMESTAMP,
    store_and_fwd_flag TEXT,
    RatecodeID INTEGER,
    PULocationID INTEGER,
    DOLocationID INTEGER,
    passenger_count INTEGER,
    trip_distance FLOAT,
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    ehail_fee FLOAT,
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    congestion_surcharge FLOAT,
    payment_type INTEGER,
    trip_type INTEGER
);

CREATE TABLE IF NOT EXISTS taxi_zones (
    LocationID INTEGER,
    Borough TEXT,
    Zone TEXT,
    service_zone TEXT
);
```

### Load Data

Using the ingest_data.py script:

```bash
python ingest_data.py \
  --user postgres \
  --password postgres \
  --host localhost \
  --port 5433 \
  --db ny_taxi \
  --table_name green_taxi_trips \
  --url https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet
```

Load taxi zones:

```bash
docker exec -it postgres psql -U postgres -d ny_taxi -c "\COPY taxi_zones FROM 'taxi_zone_lookup.csv' WITH (FORMAT csv, HEADER true);"
```

---

## Homework Questions and Answers

### Question 1: Understanding Docker Images

**Task:** Run Docker with the `python:3.13` image using an entrypoint bash.

**Command:**

```bash
docker run --entrypoint=bash python:3.13 -c "pip --version"
```

**Answer:** pip 25.3

---

### Question 2: Understanding Docker Networking and docker-compose

**Task:** Given the docker-compose.yaml, what hostname and port should pgAdmin use to connect to the Postgres database?

**docker-compose.yaml reference:**

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

**Answer:** 
Hostname: `postgres` (the container name)  
Port: `5432` (the internal container port)

---

### Question 3: Counting Short Trips

**Task:** For trips in November 2025 (2025-11-01 inclusive to 2025-12-01 exclusive), how many had a trip_distance less than or equal to 1 mile?

**SQL Query:**

```sql
SELECT COUNT(*) AS short_trips_count
FROM green_taxi_trips
WHERE lpep_pickup_datetime >= '2025-11-01'
  AND lpep_pickup_datetime < '2025-12-01'
  AND trip_distance <= 1;
```

**Answer:** 8007

---

### Question 4: Longest Trip for Each Day

**Task:** Which pickup day had the longest trip distance?

*Note:* Only include trips with trip_distance < 100.

**SQL Query:**

```sql
SELECT DATE(lpep_pickup_datetime) AS pickup_day,
       MAX(trip_distance) AS max_distance
FROM green_taxi_trips
WHERE trip_distance < 100
  AND lpep_pickup_datetime >= '2025-11-01'
  AND lpep_pickup_datetime < '2025-12-01'
GROUP BY DATE(lpep_pickup_datetime)
ORDER BY max_distance DESC
LIMIT 1;
```

**Answer:** 2025-11-14 with max distance of 88.03 miles

---

### Question 5: Biggest Pickup Zone

**Task:** Which pickup zone had the largest total amount on November 18th, 2025?

**SQL Query:**

```sql
SELECT
    z."Zone" AS pickup_zone,
    SUM(t.total_amount) AS total_amount_sum
FROM green_taxi_trips t
JOIN taxi_zones z
  ON t."PULocationID" = z."LocationID"
WHERE DATE(t.lpep_pickup_datetime) = '2025-11-18'
GROUP BY z."Zone"
ORDER BY total_amount_sum DESC
LIMIT 1;
```

**Answer:** East Harlem North with total amount of $9,281.92

---

### Question 6: Largest Tip

**Task:** For passengers picked up in East Harlem North in November 2025, which drop-off zone had the largest tip?

**SQL Query:**

```sql
SELECT
    dz."Zone" AS dropoff_zone,
    MAX(t.tip_amount) AS max_tip
FROM green_taxi_trips t
JOIN taxi_zones pz
  ON t."PULocationID" = pz."LocationID"
JOIN taxi_zones dz
  ON t."DOLocationID" = dz."LocationID"
WHERE pz."Zone" = 'East Harlem North'
  AND t.lpep_pickup_datetime >= '2025-11-01'
  AND t.lpep_pickup_datetime < '2025-12-01'
GROUP BY dz."Zone"
ORDER BY max_tip DESC
LIMIT 1;
```

**Answer:** Yorkville West with max tip of $81.89

---

## Cleanup

Stop and remove all containers and volumes:

```bash
docker-compose down -v
```

---

## Notes

- All timestamps are in UTC
- Port 5433 on the host maps to port 5432 in the Postgres container
- PgAdmin can be accessed at `http://localhost:8080`
- Remember to set up the database schema before loading data
