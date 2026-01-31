#!/bin/bash
echo "=== Question 3: Counting short trips ==="
docker exec postgres psql -U postgres -d ny_taxi -c "
SELECT COUNT(*) as short_trips_count
FROM green_taxi_trips
WHERE lpep_pickup_datetime >= '2025-11-01' 
  AND lpep_pickup_datetime < '2025-12-01'
  AND trip_distance <= 1;"

echo -e "\n=== Question 4: Longest trip for each day ==="
docker exec postgres psql -U postgres -d ny_taxi -c "
SELECT DATE(lpep_pickup_datetime) as pickup_day,
       MAX(trip_distance) as max_distance
FROM green_taxi_trips
WHERE trip_distance < 100
  AND lpep_pickup_datetime >= '2025-11-01' 
  AND lpep_pickup_datetime < '2025-12-01'
GROUP BY DATE(lpep_pickup_datetime)
ORDER BY max_distance DESC
LIMIT 1;"

echo -e "\n=== Question 5: Biggest pickup zone ==="
docker exec postgres psql -U postgres -d ny_taxi -c "
SELECT 
    z.\"Zone\" as pickup_zone,
    SUM(t.total_amount) as total_amount_sum
FROM green_taxi_trips t
JOIN taxi_zones z ON t.\"PULocationID\" = z.\"LocationID\"
WHERE DATE(t.lpep_pickup_datetime) = '2025-11-18'
GROUP BY z.\"Zone\"
ORDER BY total_amount_sum DESC
LIMIT 1;"

echo -e "\n=== Question 6: Largest tip ==="
docker exec postgres psql -U postgres -d ny_taxi -c "
SELECT 
    dz.\"Zone\" as dropoff_zone,
    MAX(t.tip_amount) as max_tip
FROM green_taxi_trips t
JOIN taxi_zones pz ON t.\"PULocationID\" = pz.\"LocationID\"
JOIN taxi_zones dz ON t.\"DOLocationID\" = dz.\"LocationID\"
WHERE pz.\"Zone\" = 'East Harlem North'
  AND t.lpep_pickup_datetime >= '2025-11-01' 
  AND t.lpep_pickup_datetime < '2025-12-01'
GROUP BY dz.\"Zone\"
ORDER BY max_tip DESC
LIMIT 1;"
