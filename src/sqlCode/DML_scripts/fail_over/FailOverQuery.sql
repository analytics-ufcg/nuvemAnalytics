select sub.vm_name, sub.avg
from(
select vm.vm_name, avg(d.disk_util)
from disk as d, time_dim as t, vm_dim as vm
where d.disk_util > 0.01 and t.date_time > '2010-01-01 00:15:00' and d.id_time = t.id_time and d.id_vm = vm.id_vm
group by vm.vm_name, d.disk_util
) as sub
where sub.avg > 0.15;