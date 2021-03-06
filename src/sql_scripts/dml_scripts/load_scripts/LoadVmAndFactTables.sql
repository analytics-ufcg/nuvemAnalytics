-- Import the CSV files with the generated data
-- ATTENTION: Do not change the importing order, the foreign keys could not permit loading

-- VM table files
COPY vm_dim
FROM local '/home/dbadmin/git/nuvemAnalytics/data/<?>/vm.csv'
DELIMITER ',' ENCLOSED BY '"' NULL 'NA' NO COMMIT;

-- NETWORK table files
COPY network (id_time, id_vm, net_util, pkt_per_sec)
FROM local '/home/dbadmin/git/nuvemAnalytics/data/<?>/network_1.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- DISK table files
COPY disk (id_time, id_vm, disk_util, ios_per_sec)
FROM local '/home/dbadmin/git/nuvemAnalytics/data/<?>/disk_1.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- CPU table files
COPY cpu (id_time, id_vm, cpu_util, cpu_alloc, cpu_queue)
FROM local '/home/dbadmin/git/nuvemAnalytics/data/<?>/cpu_1.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- MEMORY table files
COPY memory (id_time, id_vm, mem_util, mem_alloc, pages_per_sec) 
FROM local '/home/dbadmin/git/nuvemAnalytics/data/<?>/memory_1.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

