-- Import the CSV files with the generated data;
-- ATTENTION: Do not change the importing order, the foreign keys could not permit loading

select * from vm_dim order by id_vm;

-- VM table files
COPY vm_dim
FROM local '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/vm.csv'
DELIMITER ',' ENCLOSED BY '"' NULL 'NA' NO COMMIT;

-- NETWORK table files
COPY network (id_time, id_vm, net_util, pkt_per_sec)
FROM local '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/network_1.csv'
--	       '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/network_2.csv',
--     	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/network_3.csv',
-- 	  	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/network_4.csv',
--	       '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/network_5.csv',
--     	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/network_6.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- DISK table files
COPY disk (id_time, id_vm, disk_util, ios_per_sec)
FROM local '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/disk_1.csv'
--		   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/disk_2.csv',
--		   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/disk_3.csv',
-- 	  	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/disk_4.csv',
--	       '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/disk_5.csv',
--     	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/disk_6.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- CPU table files
COPY cpu (id_time, id_vm, cpu_util, cpu_alloc, cpu_queue)
FROM local '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/cpu_1.csv'
--		   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/cpu_2.csv',
--		   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/cpu_3.csv',
-- 	  	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/cpu_4.csv',
--	       '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/cpu_5.csv',
--     	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/cpu_6.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- MEMORY table files
COPY memory (id_time, id_vm, mem_util, mem_alloc, pages_per_sec) 
FROM local '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/memory_1.csv'
--		   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/memory_2.csv',
--		   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/memory_3.csv',
-- 	  	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/memory_4.csv',
--	       '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/memory_5.csv',
--     	   '/home/nuvem/Área de Trabalho/nuvemAnalytics/data/output/memory_6.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

