SELECT V.vm_name, tabelaCpu.cpu_percentile, tabelaDisk.ios_percentile, tabelaNet.pkt_percentile
FROM vm_dim V,
	 (SELECT DISTINCT C.id_vm, PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY C.cpu_alloc)
	 				 		   OVER (PARTITION BY C.id_vm) AS cpu_percentile
	  FROM cpu C, time_dim T
	  WHERE T.date_time >= '2012-12-01 00:00:00' and 
	  		T.date_time <= '2013-01-01 00:00:00' and 
	  		C.id_time = T.id_time) AS tabelaCpu,
	 (SELECT DISTINCT D.id_vm, PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY D.ios_per_sec)
	 				  		   OVER (PARTITION BY D.id_vm) AS ios_percentile
	  FROM disk D, time_dim T
	  WHERE T.date_time >= '2012-12-01 00:00:00' and 
	  		T.date_time <= '2013-01-01 00:00:00' and 
	  		D.id_time = T.id_time) AS tabelaDisk,
	 (SELECT DISTINCT N.id_vm, PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY N.pkt_per_sec)
	 				  		   OVER (PARTITION BY N.id_vm) AS pkt_percentile
	  FROM network N, time_dim T
	  WHERE T.date_time >= '2012-12-01 00:00:00' and 
	  		T.date_time <= '2013-01-01 00:00:00' and 
	  		N.id_time = T.id_time) AS tabelaNet
where tabelaCpu.cpu_percentile < 100000000 and
	  tabelaDisk.ios_percentile < 100000000 and
	  tabelaNet.pkt_percentile < 1000000000 and
	  tabelaCpu.id_vm = V.id_vm and 
	  tabelaCpu.id_vm = tabelaDisk.id_vm and
	  tabelaDisk.id_vm = tabelaNet.id_vm;
