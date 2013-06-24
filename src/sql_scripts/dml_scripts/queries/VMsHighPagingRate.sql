SELECT V.vm_name, Mem.pages_per_sec_percentile, Mem.mem_util_percentile
FROM (SELECT DISTINCT M.id_vm, 
					  PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY M.pages_per_sec) OVER (PARTITION BY M.id_vm) AS pages_per_sec_percentile, 
					  PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY M.mem_util) OVER (PARTITION BY M.id_vm) AS mem_util_percentile
	  FROM vm_dim V, memory M, time_dim T
	  WHERE T.date_time >= '2007-06-01 00:00:00' and 
	  		T.date_time <= '2019-01-01 00:00:00' and 
	  		M.id_time = T.id_time) as Mem, 
	  vm_dim V
WHERE Mem.mem_util_percentile > 0.65 and
	  Mem.pages_per_sec_percentile > 1 and
	  V.id_vm = Mem.id_vm
ORDER BY Mem.pages_per_sec_percentile DESC;