--CREATE SCHEMA MultiStarV1;
--GRANT USAGE ON SCHEMA MultiStarV1 TO vertica;

CREATE TABLE IF NOT EXISTS time (
	id_time		INTEGER NOT NULL PRIMARY KEY,
	date_time	TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vm (
	id_vm		INTEGER NOT NULL PRIMARY KEY,
	vm_name		VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS network (
	id_net		INTEGER NOT NULL PRIMARY KEY,
	id_time		INTEGER NOT NULL,
	id_vm		INTEGER NOT NULL,
	net_util	FLOAT,
	pkt_per_sec	FLOAT,
	FOREIGN KEY (id_time) REFERENCES time (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm (id_vm)
);

CREATE TABLE IF NOT EXISTS disk (
	id_disk		INTEGER NOT NULL PRIMARY KEY,
	id_time		INTEGER NOT NULL,
	id_vm		INTEGER NOT NULL,
	disk_util	FLOAT,
	ios_per_sec	FLOAT,
	FOREIGN KEY (id_time) REFERENCES time (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm (id_vm)
);

CREATE TABLE IF NOT EXISTS cpu (
	id_cpu			INTEGER NOT NULL PRIMARY KEY,
	id_time			INTEGER NOT NULL,
	id_vm			INTEGER NOT NULL,
	cpu_util		FLOAT,
	cpu_alloc		FLOAT,
	cpu_queue		FLOAT,
	cpu_growrate	FLOAT,
	cpu_headroom	FLOAT,
	FOREIGN KEY (id_time) REFERENCES time (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm (id_vm)
);	

CREATE TABLE IF NOT EXISTS memory (
	id_mem			INTEGER NOT NULL PRIMARY KEY,
	id_time			INTEGER NOT NULL,
	id_vm			INTEGER NOT NULL,
	mem_util		FLOAT,
	mem_alloc		FLOAT,
	pages_per_sec	FLOAT,
	FOREIGN KEY (id_time) REFERENCES time (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm (id_vm)
);

CREATE TABLE IF NOT EXISTS other_metrics (
	id_other			INTEGER NOT NULL PRIMARY KEY,
	id_time				INTEGER NOT NULL,
	id_vm				INTEGER NOT NULL,
	mem_headroom		FLOAT,
	disk_io_headroom	FLOAT,
	net_io_headroom		FLOAT,
	five_star			FLOAT,
	minutes_sustained	FLOAT,
	FOREIGN KEY (id_time) REFERENCES time (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm (id_vm)
);	

