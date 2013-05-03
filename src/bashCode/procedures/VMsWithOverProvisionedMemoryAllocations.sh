#!/bin/bash


VALUE=`/opt/vertica/bin/vsql -c "SELECT V.vm_name, M.mem_util, M.mem_alloc FROM vm_dim V, memory M WHERE V.id_vm = M.id_vm and M.mem_util in (SELECT max(M.mem_util) FROM memory M GROUP BY M.id_vm) and M.mem_util < 0.35 and M.mem_alloc > 0.25 ORDER BY M.mem_util;"`

echo $VALUE

exit 0
