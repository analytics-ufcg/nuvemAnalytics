SELECT V.vm_name, Cpu.cpu_queue_percentile, Cpu.cpu_util_percentile, Cpu.avg_cpu_util
FROM (SELECT DISTINCT C.id_vm,
				 	  PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY C.cpu_queue) OVER (PARTITION BY C.id_vm) AS cpu_queue_percentile,
				 	  PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY C.cpu_util) OVER (PARTITION BY C.id_vm) AS cpu_util_percentile,
				 	  AVG(C.cpu_util) OVER (PARTITION BY C.id_vm) AS avg_cpu_util
	  FROM cpu C, time_dim T
	  WHERE T.date_time >= '2008-06-01 00:00:00' and 
	  		T.date_time <= '2013-01-01 00:00:00' and 
	  		C.id_time = T.id_time) as Cpu, 
	  vm_dim V
WHERE Cpu.cpu_queue_percentile >= 0 and
	  V.id_vm = Cpu.id_vm
ORDER BY Cpu.cpu_queue_percentile;