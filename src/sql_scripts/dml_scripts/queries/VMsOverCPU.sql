SELECT DISTINCT V.vm_name, C.cpu_util, C.cpu_alloc
FROM vm_dim V, cpu C, time_dim T
WHERE V.id_vm = C.id_vm and
    T.date_time >= '2007-12-31 00:00:00' and 
    T.date_time <= '2013-01-01 00:00:00' and
    T.id_time = C.id_time and
	(V.id_vm, C.cpu_util) in 
  		(SELECT id_vm, max(C.cpu_util)
         FROM cpu C, time_dim T
         WHERE T.date_time >= '2007-12-31 00:00:00' and T.date_time <= '2013-01-01 00:00:00' and T.id_time = C.id_time 
     	 GROUP BY C.id_vm) and
    C.cpu_util < 1.1 and
    C.cpu_alloc >= 1 
ORDER BY C.cpu_util DESC;

-- TODO: O DISTINCT não faz o que queremos, deve existir 