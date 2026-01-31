-- Check some sample data
SELECT 'green_taxi_trips' as table_name, COUNT(*) as row_count FROM green_taxi_trips
UNION ALL
SELECT 'taxi_zones' as table_name, COUNT(*) as row_count FROM taxi_zones;

-- Check a few sample trips
SELECT lpep_pickup_datetime, trip_distance, total_amount 
FROM green_taxi_trips 
LIMIT 5;
