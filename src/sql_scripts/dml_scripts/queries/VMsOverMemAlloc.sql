SELECT DISTINCT V.vm_name, M.mem_util, M.mem_alloc  
FROM vm_dim V, memory M, time_dim T
WHERE V.id_vm = M.id_vm and T.date_time >= '2012-12-31 00:00:00' and T.date_time <= '2013-01-01 00:00:00' and T.id_time = M.id_time and
	(V.id_vm, M.mem_util) in 
		(SELECT id_vm, max(M.mem_util) 
		 FROM memory M, time_dim T
		 WHERE T.date_time >= '2012-12-31 00:00:00' and T.date_time <= '2013-01-01 00:00:00' and T.id_time = M.id_time
		 GROUP BY M.id_vm) 
	and M.mem_util < 0.35 and M.mem_alloc > 0.25
 ORDER BY M.mem_util, M.mem_alloc;
 
