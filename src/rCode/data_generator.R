rm(list =ls())

# =============================================================================
# FUNCTIONS
# =============================================================================

# ------------------------------------------------------------------------------
# TIME Functions
# ------------------------------------------------------------------------------
CriarDATE_TIME <- function(first.start.time, last.start.time, trace.size){
  date.time <- seq(from=first.start.time, 
                   to=(last.start.time + (trace.size-1) * 300), by=300)
  return(as.POSIXct(date.time, origin = "1970-01-01"))
}

GetTIME_ID <- function(trace.size){
  start.time <- as.POSIXct(sample(seq(from=first.start.time, to=last.start.time, by=300), 1), 
                           origin = "1970-01-01")
  initial.index <- which(time.table$date_time == start.time)
  return(seq(from=initial.index, to=(initial.index + trace.size - 1), by = 1))
}

# ------------------------------------------------------------------------------
# NETWORK Functions
# ------------------------------------------------------------------------------
CriarNET_UTIL <- function(trace.size, population.data, num.fail.metrics){
  net.util = filter(rnorm(trace.size, 0, 1), filter=rep(1, min(trace.size, 50)), 
                    circular=TRUE)
  if (length(net.util) > 1){
    net.util <- (net.util - min(net.util))/(max(net.util)-min(net.util))
  }
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(net.util))
  net.util[sample(which(!is.na(net.util)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(round(net.util, round.digits))
}
CriarPKT_PER_SEC <- function(trace.size, population.data, num.fail.metrics){
  pkt.sec = runif(trace.size, 0, 20)
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(pkt.sec))
  pkt.sec[sample(which(!is.na(pkt.sec)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(round(pkt.sec, round.digits))
}

# ------------------------------------------------------------------------------
# DISK Functions
# ------------------------------------------------------------------------------
CriarDISK_UTIL <- function(trace.size, population.data, num.fail.metrics){
  disk.util = filter(rnorm(trace.size, 0, 1), filter=rep(1, min(trace.size, 50)), 
                     circular=TRUE)
  
  if (length(disk.util) > 1){
    disk.util <- (disk.util - min(disk.util))/(max(disk.util)-min(disk.util))
  }
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(disk.util))
  disk.util[sample(which(!is.na(disk.util)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(round(disk.util, round.digits))
}
CriarIOS_PER_SEC <- function(trace.size, population.data, num.fail.metrics){
  ios.sec = runif(trace.size, 0, 20)
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(ios.sec))
  ios.sec[sample(which(!is.na(ios.sec)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(round(ios.sec, round.digits))
}

# ------------------------------------------------------------------------------
# CPU Functions
# ------------------------------------------------------------------------------
CriarCPU_UTIL <- function(trace.size, population.data, num.fail.metrics){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  cpu.util = jitter(population.data[1:trace.size])
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(cpu.util))
  cpu.util[sample(which(!is.na(cpu.util)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(round(cpu.util, round.digits))
}
CriarCPU_ALLOC <- function(trace.size, population.data, num.fail.metrics){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(population.data))
  population.data[sample(which(!is.na(population.data)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(population.data[1:trace.size])
}
CriarCPU_QUEUE <- function(trace.size, population.data, num.fail.metrics){
  cpu.queue = rep(0, trace.size)

  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(cpu.queue))
  cpu.queue[sample(which(!is.na(cpu.queue)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(cpu.queue)
}

# ------------------------------------------------------------------------------
# MEMORY Functions
# ------------------------------------------------------------------------------
CriarMEM_UTIL <- function(trace.size, population.data, num.fail.metrics){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  mem.util = jitter(population.data[1:trace.size])
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(mem.util))
  mem.util[sample(which(!is.na(mem.util)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(round(mem.util, round.digits))
}
CriarMEM_ALLOC <- function(trace.size, population.data, num.fail.metrics){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(population.data))
  population.data[sample(which(!is.na(population.data)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(population.data[1:trace.size])
}
CriarPAGES_PER_SEC <- function(trace.size, population.data, num.fail.metrics){
  pages.sec = runif(trace.size, 0, 20)
  
  # Generate the Fail Metrics
  num.fail.metrics <- num.fail.metrics - sum(is.na(pages.sec))
  pages.sec[sample(which(!is.na(pages.sec)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  
  return(round(pages.sec, round.digits))
}

# =============================================================================
# MAIN
# =============================================================================
args <- commandArgs(trailingOnly = TRUE)

# Input Arguments
# traces.dir <- args[1]                       # "data/traces/"
# output.dir <- args[2]                       # "data/output/"
# initial.vm <- as.integer(args[3])           # 1 (for example)
# final.vm <- as.integer(args[4])             # 100 (for example)
# perc.fail.collect <- as.numeric(args[5])    # 0.01 (for example)
# perc.fail.metric <- as.numeric(args[6])     # 0.05 (for example)

# Test Arguments
traces.dir <- "data/traces/"
output.dir <- "data/output/"
initial.vm <- 1
final.vm <- 2
perc.fail.collect <- 0.01
perc.fail.metric <- 0.05

# Fixed Input Arguments
min.trace.size <- 105120 # Evandro's Requirement: (60/5) * 24 * 365 * 1 (1 year in minutes) = 105120
max.trace.size <- 315360 # Evandro's Requirement: (60/5) * 24 * 365 * 3 (3 year in minutes) = 315360
round.digits <- 6
first.start.time <- 1199145600 # 01/01/2008
last.start.time <- 1262304000  # 01/01/2010 (the last possible time will be at 01/01/2013)

# Output directory creation
dir.create(output.dir, showWarnings=F)

# Temp variables
file.index <- 1
curr.file.rows <- 0
max.file.rows <- 10000000 # MAX = 10 million rows (50 vm's per file on average)
base.trace.files <- paste(traces.dir, list.files(traces.dir), sep ="")

# Create the TIME table
cat("Creating the TIME table...\n")
time.table <- data.frame(date_time=CriarDATE_TIME(first.start.time, last.start.time, max.trace.size))
time.table$id_time <- seq_len(nrow(time.table))
time.table <- time.table[,c("id_time", "date_time")]

# Write the TIME table (if it does not exists)
cat("Writing the TIME table (if it doesn't exist)...\n")
time.table.file <- paste(output.dir, "time.csv", sep = "")
if (!file.exists(time.table.file)){
  write.table(time.table, time.table.file, col.names = F, row.names=F, sep = ",")
}

cat("Start generating the VM trace data...\n")
for (vm in seq(initial.vm, final.vm)){
  runtime.start <- Sys.time()
  trace.size <- sample(seq(from=min.trace.size, to=max.trace.size), 1) 
  cat("  VM:", vm, "- Trace size:", trace.size, "... ")
  
  base.trace <- read.csv(base.trace.files[(vm %% length(base.trace.files)) + 1])
  
  vm.table <- data.frame(id_vm=vm,
                         vm_name=paste("VM_", vm, sep = ""))
  
  # ----------------------------------------------------------------------------
  # Complete Raw Data Generation (with indisponible metrics)
  # ----------------------------------------------------------------------------
  
  num.fail.metrics <- floor(perc.fail.metric * trace.size)
  
  trace.table <- data.frame(id_time=GetTIME_ID(trace.size), 
                            id_vm=rep(vm, trace.size),
                            net_util=CriarNET_UTIL(trace.size, base.trace$NET_UTIL, num.fail.metrics),
                            pkt_per_sec=CriarPKT_PER_SEC(trace.size, NA, num.fail.metrics),
                            disk_util=CriarDISK_UTIL(trace.size, NA, num.fail.metrics),
                            ios_per_sec=CriarIOS_PER_SEC(trace.size, NA, num.fail.metrics),
                            cpu_util=CriarCPU_UTIL(trace.size, base.trace$CPU_UTIL, num.fail.metrics),
                            cpu_alloc=CriarCPU_ALLOC(trace.size, base.trace$CPU_ALLOC, num.fail.metrics),
                            cpu_queue=CriarCPU_QUEUE(trace.size, NA, num.fail.metrics),
                            memory_util=CriarMEM_UTIL(trace.size, base.trace$MEM_UTIL, num.fail.metrics),
                            memory_alloc=CriarMEM_ALLOC(trace.size, base.trace$MEM_ALLOC, num.fail.metrics),
                            pages_per_sec=CriarPAGES_PER_SEC(trace.size, NA, num.fail.metrics))
  
  # ----------------------------------------------------------------------------
  # Indisponible Row Generation
  # ----------------------------------------------------------------------------
  # Check for rows with no metric collected and Remove them
  rows.with.no.metric <- rowSums(is.na(trace.table))
  rows.with.no.metric <- which(rows.with.no.metric == 10)
  if (length(rows.with.no.metric) > 0){
    trace.table <- trace.table[-rows.with.no.metric,]
  }
  # Count the quantity of indisponible rows (minus the already removed)
  indisponible.rows <- floor(trace.size * perc.fail.collect) - length(rows.with.no.metric)
  # Remove randomly that quantity of rows
  trace.table <- trace.table[-sample(seq_len(nrow(trace.table)), indisponible.rows, replace=F),]
  
  # ----------------------------------------------------------------------------
  # Append trace data to files
  # ----------------------------------------------------------------------------
  write.table(vm.table, paste(output.dir, "vm.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  
  write.table(trace.table[,c("id_time", "id_vm", "net_util", "pkt_per_sec")], 
              paste(output.dir, "network_", file.index,".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(trace.table[,c("id_time", "id_vm", "disk_util", "ios_per_sec")], 
              paste(output.dir, "disk_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(trace.table[,c("id_time", "id_vm", "cpu_util", "cpu_alloc", "cpu_queue")], 
              paste(output.dir, "cpu_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(trace.table[,c("id_time", "id_vm", "memory_util", "memory_alloc", "pages_per_sec")], 
              paste(output.dir, "memory_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  
  # Split the file by the quantity of rows (the vm file is unique)
  curr.file.rows = curr.file.rows + trace.size
  if (curr.file.rows >= max.file.rows){
    file.index <- file.index + 1
    curr.file.rows <- 0
  }
  
  runtime <- Sys.time() - runtime.start
  cat(round(runtime[[1]], 2), attr(runtime, "units"), "\n")
}

