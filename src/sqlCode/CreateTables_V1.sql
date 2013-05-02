-- Create the tables from the Multidimensional Star Schema - Version 1

CREATE TABLE IF NOT EXISTS time_dim (
	id_time		INTEGER,
	date_time	TIMESTAMP,
	PRIMARY KEY (id_time)
);

CREATE TABLE IF NOT EXISTS vm_dim (
	id_vm		INTEGER,
	vm_name		VARCHAR(64),
	PRIMARY KEY (id_vm)
);

CREATE TABLE IF NOT EXISTS network (
	id_net		AUTO_INCREMENT,
	id_time		INTEGER NOT NULL,
	id_vm		INTEGER NOT NULL,
	net_util	FLOAT,
	pkt_per_sec	FLOAT,
	PRIMARY KEY (id_net),
	FOREIGN KEY (id_time) REFERENCES time_dim (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm_dim (id_vm)
);

CREATE TABLE IF NOT EXISTS disk (
	id_disk		AUTO_INCREMENT,
	id_time		INTEGER NOT NULL,
	id_vm		INTEGER NOT NULL,
	disk_util	FLOAT,
	ios_per_sec	FLOAT,
	PRIMARY KEY (id_disk),
	FOREIGN KEY (id_time) REFERENCES time_dim (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm_dim (id_vm)
);

CREATE TABLE IF NOT EXISTS cpu (
	id_cpu			AUTO_INCREMENT,
	id_time			INTEGER NOT NULL,
	id_vm			INTEGER NOT NULL,
	cpu_util		FLOAT,
	cpu_alloc		FLOAT,
	cpu_queue		FLOAT,
	cpu_growrate	FLOAT,
	cpu_headroom	FLOAT,
	PRIMARY KEY (id_cpu),
	FOREIGN KEY (id_time) REFERENCES time_dim (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm_dim (id_vm)
);	

CREATE TABLE IF NOT EXISTS memory (
	id_mem			AUTO_INCREMENT,
	id_time			INTEGER NOT NULL,
	id_vm			INTEGER NOT NULL,
	mem_util		FLOAT,
	mem_alloc		FLOAT,
	pages_per_sec	FLOAT,
	PRIMARY KEY (id_mem),
	FOREIGN KEY (id_time) REFERENCES time_dim (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm_dim (id_vm)
);

CREATE TABLE IF NOT EXISTS other_metrics (
	id_other			AUTO_INCREMENT,
	id_time				INTEGER NOT NULL,
	id_vm				INTEGER NOT NULL,
	mem_headroom		FLOAT,
	disk_io_headroom	FLOAT,
	net_io_headroom		FLOAT,
	five_star			FLOAT,
	minutes_sustained	FLOAT,
	PRIMARY KEY (id_other),
	FOREIGN KEY (id_time) REFERENCES time_dim (id_time),
	FOREIGN KEY (id_vm) REFERENCES vm_dim (id_vm)
);	

