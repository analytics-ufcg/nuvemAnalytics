SELECT V.vm_name, Net.pkt_percentile 
FROM (SELECT DISTINCT N.id_vm, PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY N.pkt_per_sec) 
					  		   OVER (PARTITION BY N.id_vm) AS pkt_percentile
	  FROM vm_dim V, network N, time_dim T
	  WHERE T.date_time >= '2011-06-01 00:00:00' and 
	  		T.date_time <= '2013-01-01 00:00:00' and 
	  		N.id_time = T.id_time) as Net, 
	  vm_dim V
WHERE Net.pkt_percentile > 95 and
	  V.id_vm = Net.id_vm;

	  
