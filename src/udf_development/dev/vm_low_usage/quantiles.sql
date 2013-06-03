\set libfile '\''`pwd`'/quantiles.R\''
CREATE LIBRARY nuvlib2 AS :libfile LANGUAGE 'R';

CREATE OR REPLACE TRANSFORM FUNCTION VMLowUsageFunc
AS LANGUAGE 'R' NAME 'VMLowUsageFuncFactory' LIBRARY nuvlib2;

CREATE OR REPLACE TRANSFORM FUNCTION VMLowUsageFuncWithTime
AS LANGUAGE 'R' NAME 'VMLowUsageFuncWithTimeFactory' LIBRARY nuvlib29;

-- Low Usage VMs query using UDTFs as subqueries

SELECT VM.vm_name, tabelaCpu.col1 as cpu_alloc, tabelaDisk.col1 as ios_per_sec, tabelaNet.col1 as pkt_per_sec
FROM (SELECT VMLowUsageFuncWithTime(C.id_vm, C.cpu_alloc, 0.9, 5.0, C.id_time)
	  OVER ()
	  FROM cpu C) as tabelaCpu,
	 (SELECT VMLowUsageFunc(D.id_vm, D.ios_per_sec, 0.9, 1000.0)
	  OVER ()
	  FROM disk D) as tabelaDisk,
	 (SELECT VMLowUsageFunc(N.id_vm, N.pkt_per_sec, 0.9, 300000000.0)
	  OVER ()
	  FROM network N) as tabelaNet, time_dim as T, vm_dim as VM
WHERE tabelaCpu.id_vm = tabelaDisk.id_vm and tabelaDisk.id_vm = tabelaNet.id_vm and 
	T.date_time >= '2007-01-31 08:15:00' and T.date_time <= '2013-01-31 08:15:00' and 
	tabelaCpu.id_time = T.id_time and VM.id_vm = tabelaCpu.id_vm;

DROP LIBRARY nuvlib2 CASCADE;
