DROP LIBRARY nuvlib CASCADE;

\set libfile '\''`pwd`'/vm_over_memory.R\''
CREATE LIBRARY nuvlib AS :libfile LANGUAGE 'R';

CREATE OR REPLACE TRANSFORM FUNCTION VMOverMemoryFunc
AS LANGUAGE 'R' NAME 'VMOverMemoryFuncFactory' LIBRARY nuvlib;

-- VMs with over memory allocation query using UDTFs

-- PARAMETERS
\set start_date '\'2007-01-31 08:15:00\''
\set final_date '\'2010-01-31 08:15:00\''
\set max_mem_util 0.35		-- Alternative value: 0.95
\set min_mem_alloc 0.25		-- Alternative value: 0.15

SELECT VMOverMemoryFunc(V.id_vm, V.vm_name, M.mem_util, M.mem_alloc, T.date_time, 
			cast(:start_date as DATETIME), cast(:final_date as DATETIME), :max_mem_util, :min_mem_alloc) 
OVER (partition by V.id_vm) 
FROM vm_dim V, memory M, time_dim T 
WHERE V.id_vm = M.id_vm and T.id_time = M.id_time;

DROP LIBRARY nuvlib CASCADE;
