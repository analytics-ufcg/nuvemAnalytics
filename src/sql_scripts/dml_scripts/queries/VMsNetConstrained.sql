SELECT V.vm_name, Net.pkt_per_sec 
FROM (SELECT N.id_vm, N.id_time, N.pkt_per_sec, NTILE(100) OVER (PARTITION BY N.id_vm ORDER BY N.pkt_per_sec) as pkt_p
	  FROM vm_dim V, network N) as Net, 
	  time_dim T, vm_dim V
WHERE Net.pkt_p > 90 and 
	  Net.pkt_per_sec > 95 and
	  V.id_vm = Net.id_vm and 
	  T.date_time >= '2012-12-01 00:00:00' and 
	  T.date_time <= '2013-01-01 00:00:00' and 
	  Net.id_time = T.id_time;

	  -- TODO: NTILE deve ser calculado sobre cada VM, talvez o partition by resolva...