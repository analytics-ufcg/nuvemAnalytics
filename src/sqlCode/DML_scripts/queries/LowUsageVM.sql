select tabelaCpu.vm_name, tabelaCpu.cpu_alloc, tabelaDisk.ios_p, tabelaNet.pkt_p
from (select V.vm_name, V.id_vm, C.cpu_alloc, NTILE(100) OVER(order by C.cpu_alloc) as cpu_p 
	  from vm_dim V, cpu C 
	  where (V.id_vm = C.id_vm)) as tabelaCpu,
	 (select V.vm_name, V.id_vm, D.ios_per_sec, NTILE(100) OVER(order by D.ios_per_sec) as ios_p 
	  from vm_dim V, disk D 
	  where (V.id_vm = D.id_vm)) as tabelaDisk,
	 (select V.vm_name, V.id_vm, N.pkt_per_sec, NTILE(100) OVER(order by N.pkt_per_sec) as pkt_p
	  from vm_dim V, network N 
	  where (V.id_vm = N.id_vm)) as tabelaNet 
where tabelaCpu.cpu_p > 90 and tabelaCpu.cpu_alloc < 0.2 and
	  tabelaDisk.ios_p > 90 and tabelaDisk.ios_per_sec < 1.0 and
	  tabelaNet.pkt_p > 90 and tabelaNet.pkt_p < 3.0 and
	  tabelaCpu.id_vm = tabelaDisk.id_vm and tabelaDisk.id_vm = tabelaNet.id_vm;
