select count(*)
from(
	select vm.vm_name, avg(d.disk_util)
	from cpu as c, disk as d, time_dim as t, vm_dim as vm
	where d.disk_util > 0.1 and t.date_time > '2011-01-01 00:15:00' and 
		  d.id_time = t.id_time and c.id_time = t.id_time and d.id_vm = vm.id_vm
	group by vm.vm_name, d.disk_util
) as sub
where sub.avg > 0.15 and sub.avg < 0.151;

-- Check the Cluster K-Safety
SELECT current_fault_tolerance FROM system;