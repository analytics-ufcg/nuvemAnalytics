-- Import the CSV files with the generated data;
-- ATTENTION: Do not change the importing order, the foreign keys could not permit loading

-- VM table files
COPY vm_dim
FROM '/home/vertica/raw_data/vm.csv'
DELIMITER ',' ENCLOSED BY '"' NULL 'NA' NO COMMIT;

-- NETWORK table files
COPY network (id_time, id_vm, net_util, pkt_per_sec)
FROM '/home/vertica/raw_data/network_1.csv', 
     '/home/vertica/raw_data/network_2.csv',
     '/home/vertica/raw_data/network_3.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- DISK table files
COPY disk (id_time, id_vm, disk_util, ios_per_sec)
FROM '/home/vertica/raw_data/disk_1.csv', 
     '/home/vertica/raw_data/disk_2.csv',
     '/home/vertica/raw_data/disk_3.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- CPU table files
COPY cpu (id_time, id_vm, cpu_util, cpu_alloc, cpu_queue)
FROM '/home/vertica/raw_data/cpu_1.csv',
     '/home/vertica/raw_data/cpu_2.csv',
     '/home/vertica/raw_data/cpu_3.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- MEMORY table files
COPY memory (id_time, id_vm, mem_util, mem_alloc, pages_per_sec) 
FROM '/home/vertica/raw_data/memory_1.csv',
     '/home/vertica/raw_data/memory_2.csv',
     '/home/vertica/raw_data/memory_3.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;