-- Import the TIME table from a CSV file
-- The Time table is imported separatedly because it never changes
-- In the interval: 01/01/2010 00:00:00 to 01/01/2013 00:00:00 (with 5 minutes granularity)

-- TIME table files
COPY time_dim
FROM '/home/vertica/raw_data/time.csv'
DELIMITER ',' ENCLOSED BY '"' NULL 'NA' NO COMMIT;