-- Import the CSV files with the generated data;
-- ATTENTION: Do not change the importing order, the foreign keys could not permit loading

-- TIME table files
COPY time_dim
FROM '/home/vertica/raw_data/time.csv' DELIMITER ',' ENCLOSED BY '"' NO COMMIT;

-- VM table files
COPY vm_dim
FROM '/home/vertica/raw_data/vm.csv' DELIMITER ',' ENCLOSED BY '"' NO COMMIT;

-- NETWORK table files
COPY network (id_time, id_vm, net_util, pkt_per_sec)
FROM '/home/vertica/raw_data/network_1.csv' DELIMITER ',' NO COMMIT;

-- DISK table files
COPY disk (id_time, id_vm, disk_util, ios_per_sec)
FROM '/home/vertica/raw_data/disk_1.csv' DELIMITER ',' NO COMMIT;

-- CPU table files
COPY cpu (id_time, id_vm, cpu_util, cpu_alloc, cpu_queue, cpu_growrate, cpu_headroom)
FROM '/home/vertica/raw_data/cpu_1.csv' DELIMITER ',' NO COMMIT;

-- MEMORY table files
COPY memory (id_time, id_vm, mem_util, mem_alloc, pages_per_sec) 
FROM '/home/vertica/raw_data/memory_1.csv' DELIMITER ',' NO COMMIT;

-- OTHER_METRICS table files
COPY other_metrics (id_time, id_vm, mem_headroom, disk_io_headroom, net_io_headroom, five_star, minutes_sustained)
FROM '/home/vertica/raw_data/other_1.csv' DELIMITER ',' NO COMMIT;
