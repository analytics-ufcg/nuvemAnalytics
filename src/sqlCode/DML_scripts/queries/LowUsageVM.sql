--select VMsOverMemAlloc('2011-01-31 08:15:00', '2013-01-31 08:15:00');

select tabelaCpu.vm_name, tabelaCpu.cpu_alloc, tabelaDisk.ios_p 
from (select V.vm_name, C.cpu_alloc, NTILE(10) OVER(order by C.cpu_alloc) as cpu_p 
	  from vm_dim V, cpu C 
	  where (V.id_vm = C.id_vm)) as tabelaCpu,
	  (select V.vm_name, D.ios_per_sec, NTILE(10) OVER(order by D.ios_per_sec) as ios_p 
	  from vm_dim V, disk D 
	  where (V.id_vm = D.id_vm)) as tabelaDisk 
where tabelaCpu.cpu_p >= 9 and tabelaCpu.cpu_alloc >= 0.2 and
	  tabelaDisk.ios_p >= 9 and tabelaDisk.ios_per_sec >= 1.0 and
	  tabelaCpu.vm_name = tabelaDisk.vm_name;

-- Remember to change back the tabelaCpu.cpu_alloc < 0.2
-- Remember to change back the tabelaDisk.ios_p < 0.2

select vm_name, ios_per_sec 
from (select V.vm_name, D.ios_per_sec, NTILE(10) OVER(order by D.ios_per_sec) as ios_p 
	  from vm_dim V, disk D 
	  where (V.id_vm = D.id_vm)) as tabelaDisk 
where (tabelaDisk.ios_p >= 9 and tabelaDisk.ios_per_sec >= 1.0);

--select vm_name, pkt_per_sec from (select V.vm_name, N.pkt_per_sec, NTILE(10) OVER(order by N.pkt_per_sec) as pkt_p from vm_dim V, network N where (V.id_vm = N.id_vm)) as tabelaNet ) as tabelaGeral where (pkt_p >= 9 and ios_per_sec < 3.0) ;
