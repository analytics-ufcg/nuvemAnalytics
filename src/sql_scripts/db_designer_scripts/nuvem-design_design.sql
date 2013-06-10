
select mark_design_ksafe(1);

CREATE PROJECTION public."time_dim_DBD_1_seg_nuvem-design_nuvem-design" 
(
 id_time ENCODING AUTO, 
 date_time ENCODING AUTO
)
AS
 SELECT id_time, 
        date_time
 FROM public.time_dim 
 ORDER BY id_time
SEGMENTED BY MODULARHASH (id_time) ALL NODES OFFSET 0;

CREATE PROJECTION public."time_dim_DBD_2_seg_nuvem-design_nuvem-design" 
(
 id_time ENCODING AUTO, 
 date_time ENCODING AUTO
)
AS
 SELECT id_time, 
        date_time
 FROM public.time_dim 
 ORDER BY id_time
SEGMENTED BY MODULARHASH (id_time) ALL NODES OFFSET 1;

CREATE PROJECTION public."vm_dim_DBD_3_seg_nuvem-design_nuvem-design" 
(
 id_vm ENCODING AUTO, 
 vm_name ENCODING AUTO
)
AS
 SELECT id_vm, 
        vm_name
 FROM public.vm_dim 
 ORDER BY id_vm
SEGMENTED BY MODULARHASH (id_vm) ALL NODES OFFSET 0;

CREATE PROJECTION public."vm_dim_DBD_4_seg_nuvem-design_nuvem-design" 
(
 id_vm ENCODING AUTO, 
 vm_name ENCODING AUTO
)
AS
 SELECT id_vm, 
        vm_name
 FROM public.vm_dim 
 ORDER BY id_vm
SEGMENTED BY MODULARHASH (id_vm) ALL NODES OFFSET 1;

CREATE PROJECTION public."network_DBD_5_seg_nuvem-design_nuvem-design" 
(
 id_net ENCODING AUTO, 
 id_time ENCODING AUTO, 
 id_vm ENCODING AUTO, 
 net_util ENCODING AUTO, 
 pkt_per_sec ENCODING AUTO
)
AS
 SELECT id_net, 
        id_time, 
        id_vm, 
        net_util, 
        pkt_per_sec
 FROM public.network 
 ORDER BY id_net
SEGMENTED BY MODULARHASH (id_net) ALL NODES OFFSET 0;

CREATE PROJECTION public."network_DBD_6_seg_nuvem-design_nuvem-design" 
(
 id_net ENCODING AUTO, 
 id_time ENCODING AUTO, 
 id_vm ENCODING AUTO, 
 net_util ENCODING AUTO, 
 pkt_per_sec ENCODING AUTO
)
AS
 SELECT id_net, 
        id_time, 
        id_vm, 
        net_util, 
        pkt_per_sec
 FROM public.network 
 ORDER BY id_net
SEGMENTED BY MODULARHASH (id_net) ALL NODES OFFSET 1;

CREATE PROJECTION public."disk_DBD_7_seg_nuvem-design_nuvem-design" 
(
 id_disk ENCODING AUTO, 
 id_time ENCODING AUTO, 
 id_vm ENCODING AUTO, 
 disk_util ENCODING AUTO, 
 ios_per_sec ENCODING AUTO
)
AS
 SELECT id_disk, 
        id_time, 
        id_vm, 
        disk_util, 
        ios_per_sec
 FROM public.disk 
 ORDER BY id_disk
SEGMENTED BY MODULARHASH (id_disk) ALL NODES OFFSET 0;

CREATE PROJECTION public."disk_DBD_8_seg_nuvem-design_nuvem-design" 
(
 id_disk ENCODING AUTO, 
 id_time ENCODING AUTO, 
 id_vm ENCODING AUTO, 
 disk_util ENCODING AUTO, 
 ios_per_sec ENCODING AUTO
)
AS
 SELECT id_disk, 
        id_time, 
        id_vm, 
        disk_util, 
        ios_per_sec
 FROM public.disk 
 ORDER BY id_disk
SEGMENTED BY MODULARHASH (id_disk) ALL NODES OFFSET 1;

CREATE PROJECTION public."cpu_DBD_9_seg_nuvem-design_nuvem-design" 
(
 id_cpu ENCODING AUTO, 
 id_time ENCODING AUTO, 
 id_vm ENCODING AUTO, 
 cpu_util ENCODING AUTO, 
 cpu_alloc ENCODING AUTO, 
 cpu_queue ENCODING AUTO
)
AS
 SELECT id_cpu, 
        id_time, 
        id_vm, 
        cpu_util, 
        cpu_alloc, 
        cpu_queue
 FROM public.cpu 
 ORDER BY id_cpu
SEGMENTED BY MODULARHASH (id_cpu) ALL NODES OFFSET 0;

CREATE PROJECTION public."cpu_DBD_10_seg_nuvem-design_nuvem-design" 
(
 id_cpu ENCODING AUTO, 
 id_time ENCODING AUTO, 
 id_vm ENCODING AUTO, 
 cpu_util ENCODING AUTO, 
 cpu_alloc ENCODING AUTO, 
 cpu_queue ENCODING AUTO
)
AS
 SELECT id_cpu, 
        id_time, 
        id_vm, 
        cpu_util, 
        cpu_alloc, 
        cpu_queue
 FROM public.cpu 
 ORDER BY id_cpu
SEGMENTED BY MODULARHASH (id_cpu) ALL NODES OFFSET 1;

CREATE PROJECTION public."memory_DBD_11_seg_nuvem-design_nuvem-design" 
(
 id_mem ENCODING AUTO, 
 id_time ENCODING AUTO, 
 id_vm ENCODING AUTO, 
 mem_util ENCODING AUTO, 
 mem_alloc ENCODING AUTO, 
 pages_per_sec ENCODING AUTO
)
AS
 SELECT id_mem, 
        id_time, 
        id_vm, 
        mem_util, 
        mem_alloc, 
        pages_per_sec
 FROM public.memory 
 ORDER BY id_mem
SEGMENTED BY MODULARHASH (id_mem) ALL NODES OFFSET 0;

CREATE PROJECTION public."memory_DBD_12_seg_nuvem-design_nuvem-design" 
(
 id_mem ENCODING AUTO, 
 id_time ENCODING AUTO, 
 id_vm ENCODING AUTO, 
 mem_util ENCODING AUTO, 
 mem_alloc ENCODING AUTO, 
 pages_per_sec ENCODING AUTO
)
AS
 SELECT id_mem, 
        id_time, 
        id_vm, 
        mem_util, 
        mem_alloc, 
        pages_per_sec
 FROM public.memory 
 ORDER BY id_mem
SEGMENTED BY MODULARHASH (id_mem) ALL NODES OFFSET 1;


select mark_design_ksafe(1);

