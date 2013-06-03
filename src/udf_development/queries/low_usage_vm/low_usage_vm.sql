DROP LIBRARY nuvlib2 CASCADE;

\set libfile '\''`pwd`'/low_usage_vm.R\''
CREATE LIBRARY nuvlib2 AS :libfile LANGUAGE 'R';

CREATE OR REPLACE TRANSFORM FUNCTION LowUsageVMsFunc
AS LANGUAGE 'R' NAME 'LowUsageVMsFuncFactory' LIBRARY nuvlib2;

CREATE OR REPLACE TRANSFORM FUNCTION LowUsageVMsWithTimeFunc
AS LANGUAGE 'R' NAME 'LowUsageVMsWithTimeFuncFactory' LIBRARY nuvlib2;

-- Low Usage VMs query using UDTFs

-- PARAMETERS
\set cpu_percentile 0.9 
\set cpu_max 0.2		-- Alternative value: 5.0
\set disk_percentile 0.9
\set disk_max 1			-- Alternative value: 1000.0
\set net_percentile 0.9
\set net_max 3			-- Alternative value: 300000000.0

SELECT VM.vm_name, tabelaCpu.col1 as cpu_alloc, tabelaDisk.col1 as ios_per_sec, tabelaNet.col1 as pkt_per_sec
FROM (SELECT LowUsageVMsWithTimeFunc(C.id_vm, C.cpu_alloc, :cpu_percentile, :cpu_max, C.id_time)
	  OVER ()
	  FROM cpu C) as tabelaCpu,
	 (SELECT LowUsageVMsFunc(D.id_vm, D.ios_per_sec, :disk_percentile, :disk_max)
	  OVER ()
	  FROM disk D) as tabelaDisk,
	 (SELECT LowUsageVMsFunc(N.id_vm, N.pkt_per_sec, :net_percentile, :net_max)
	  OVER ()
	  FROM network N) as tabelaNet, time_dim as T, vm_dim as VM
WHERE tabelaCpu.id_vm = tabelaDisk.id_vm and tabelaDisk.id_vm = tabelaNet.id_vm and 
	T.date_time >= '2007-01-31 08:15:00' and T.date_time <= '2013-01-31 08:15:00' and 
	tabelaCpu.id_time = T.id_time and VM.id_vm = tabelaCpu.id_vm;

DROP LIBRARY nuvlib2 CASCADE;
