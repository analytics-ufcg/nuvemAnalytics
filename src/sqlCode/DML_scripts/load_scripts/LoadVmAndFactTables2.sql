-- Import the CSV files with the generated data;
-- ATTENTION: Do not change the importing order, the foreign keys could not permit loading

-- VM table files
COPY vm_dim
FROM local '/home/augusto/git/nuvemAnalytics/data/output2/vm.csv'
DELIMITER ',' ENCLOSED BY '"' NULL 'NA' NO COMMIT;

-- NETWORK table files
COPY network (id_time, id_vm, net_util, pkt_per_sec)
FROM local '/home/augusto/git/nuvemAnalytics/data/output2/network_1.csv',
	       '/home/augusto/git/nuvemAnalytics/data/output2/network_2.csv',
     	   '/home/augusto/git/nuvemAnalytics/data/output2/network_3.csv',
 	  	   '/home/augusto/git/nuvemAnalytics/data/output2/network_4.csv',
	       '/home/augusto/git/nuvemAnalytics/data/output2/network_5.csv',
     	   '/home/augusto/git/nuvemAnalytics/data/output2/network_6.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- DISK table files
COPY disk (id_time, id_vm, disk_util, ios_per_sec)
FROM local '/home/augusto/git/nuvemAnalytics/data/output2/disk_1.csv',
		   '/home/augusto/git/nuvemAnalytics/data/output2/disk_2.csv',
		   '/home/augusto/git/nuvemAnalytics/data/output2/disk_3.csv',
 	  	   '/home/augusto/git/nuvemAnalytics/data/output2/disk_4.csv',
	       '/home/augusto/git/nuvemAnalytics/data/output2/disk_5.csv',
     	   '/home/augusto/git/nuvemAnalytics/data/output2/disk_6.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- CPU table files
COPY cpu (id_time, id_vm, cpu_util, cpu_alloc, cpu_queue)
FROM local '/home/augusto/git/nuvemAnalytics/data/output2/cpu_1.csv',
		   '/home/augusto/git/nuvemAnalytics/data/output2/cpu_2.csv',
		   '/home/augusto/git/nuvemAnalytics/data/output2/cpu_3.csv',
 	  	   '/home/augusto/git/nuvemAnalytics/data/output2/cpu_4.csv',
	       '/home/augusto/git/nuvemAnalytics/data/output2/cpu_5.csv',
     	   '/home/augusto/git/nuvemAnalytics/data/output2/cpu_6.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;

-- MEMORY table files
COPY memory (id_time, id_vm, mem_util, mem_alloc, pages_per_sec) 
FROM local '/home/augusto/git/nuvemAnalytics/data/output2/memory_1.csv',
		   '/home/augusto/git/nuvemAnalytics/data/output2/memory_2.csv',
		   '/home/augusto/git/nuvemAnalytics/data/output2/memory_3.csv',
 	  	   '/home/augusto/git/nuvemAnalytics/data/output2/memory_4.csv',
	       '/home/augusto/git/nuvemAnalytics/data/output2/memory_5.csv',
     	   '/home/augusto/git/nuvemAnalytics/data/output2/memory_6.csv'
DELIMITER ',' NULL 'NA' NO COMMIT;