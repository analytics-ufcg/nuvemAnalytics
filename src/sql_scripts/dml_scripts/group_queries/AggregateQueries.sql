SELECT over_mem_alloc.vm_name, low_usage.cpu_util
FROM (
		SELECT DISTINCT V.vm_name, M.mem_util, M.mem_alloc  
		FROM vm_dim V, memory M, time_dim T
		WHERE V.id_vm = M.id_vm and T.date_time >= '2007-12-01 00:00:00' and T.date_time <= '2013-01-01 00:00:00' and T.id_time = M.id_time and
			(V.id_vm, M.mem_util) in 
				(SELECT id_vm, max(M.mem_util) 
				 FROM memory M, time_dim T
				 WHERE T.date_time >= '2007-12-01 00:00:00' and T.date_time <= '2013-01-01 00:00:00' and T.id_time = M.id_time
				 GROUP BY M.id_vm) 
			and M.mem_util < 1.1 and M.mem_alloc > 0.25
		 ORDER BY M.mem_util, M.mem_alloc
	  ) as over_mem_alloc full outer join
--	  (
--	  	select tabelaCpu.vm_name, tabelaCpu.cpu_alloc, tabelaDisk.ios_per_sec, tabelaNet.pkt_per_sec
--		from (select V.vm_name, V.id_vm, C.cpu_alloc, C.id_time, NTILE(100) OVER(order by C.cpu_alloc) as cpu_p 
--			  from vm_dim V, cpu C 
--			  where (V.id_vm = C.id_vm)) as tabelaCpu,
--			 (select V.vm_name, V.id_vm, D.ios_per_sec, NTILE(100) OVER(order by D.ios_per_sec) as ios_p 
--			  from vm_dim V, disk D 
--			  where (V.id_vm = D.id_vm)) as tabelaDisk,
--			 (select V.vm_name, V.id_vm, N.pkt_per_sec, NTILE(100) OVER(order by N.pkt_per_sec) as pkt_p
--			  from vm_dim V, network N 
--			  where (V.id_vm = N.id_vm)) as tabelaNet, time_dim T 
--		where tabelaCpu.cpu_p > 90 and tabelaCpu.cpu_alloc < 0.2 and
--			  tabelaDisk.ios_p > 90 and tabelaDisk.ios_per_sec < 1.0 and
--			  tabelaNet.pkt_p > 90 and tabelaNet.pkt_per_sec < 3.0 and
--			  tabelaCpu.id_vm = tabelaDisk.id_vm and tabelaDisk.id_vm = tabelaNet.id_vm
--			  and T.date_time >= '2007-10-01 00:00:00' and T.date_time <= '2013-01-01 00:00:00' and tabelaCpu.id_time = T.id_time
--	  ) as low_usage
	  (
	  	select vm.vm_name, max(c.cpu_util)
	  	from vm_dim as vm, cpu as c
	  	where c.id_vm = vm.id_vm and c.cpu_util =1 
	  	group by vm.vm_name,
	  ) as low_usage on over_mem_alloc.vm_name = low_usage.vm_name;
