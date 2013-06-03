DROP LIBRARY nuvlib CASCADE;

\set libfile '\''`pwd`'/vm_over_memory.R\''
CREATE LIBRARY nuvlib AS :libfile LANGUAGE 'R';

CREATE OR REPLACE TRANSFORM FUNCTION VMOverMemoryFunc
AS LANGUAGE 'R' NAME 'VMOverMemoryFuncFactory' LIBRARY nuvlib;

SELECT VMOverMemoryFunc(V.id_vm, V.vm_name, M.mem_util, M.mem_alloc, T.date_time, cast('2007-01-31 08:15:00' as DATETIME), cast('2010-01-31 08:15:00' as DATETIME), 10, 5) OVER (partition by V.id_vm) FROM vm_dim V, memory M, time_dim T WHERE V.id_vm = M.id_vm and T.id_time = M.id_time;

--SELECT V.id_vm, V.vm_name, M.mem_util, M.mem_alloc, T.date_time FROM vm_dim V, memory M, time_dim T WHERE V.id_vm = M.id_vm and T.id_time = M.id_time;

DROP LIBRARY nuvlib CASCADE;
