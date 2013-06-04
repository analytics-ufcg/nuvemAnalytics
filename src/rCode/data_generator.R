rm(list =ls())

# =============================================================================
# FUNCTIONS
# =============================================================================

# ------------------------------------------------------------------------------
# TIME Functions
# ------------------------------------------------------------------------------
DATE_TIME <- function(first.start.time, last.start.time, trace.size){
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

NET_UTIL <- function(trace.size, population.data, num.fail.metrics){
  # NET_UTIL: Network bandwidth utilization in Mb/s (10^6 bits, megabits per second)
  
  # Generation RULE:
  # Time-serie with randon poisson (lambda = 2000) data 
  net.util <- filter(rpois(trace.size, 2000), filter=rep(1, min(trace.size, 5)), circular=TRUE)
  
  if (length(net.util) > 1){
    # Normalize to minimum 0
    if (min(net.util) < 0){
      net.util <- net.util + min(net.util) * -1
    }else{
      net.util <- net.util + min(net.util)
    }
    
    # Change the scale to Mega-bits
    net.util <- net.util/10^6
  }
  
  # Generate the Fail Metrics
  net.util <- GenerateFailMetrics(net.util, num.fail.metrics)
  
  return(round(net.util, round.digits))
}

PKT_PER_SEC <- function(trace.size, population.data, num.fail.metrics){
  # Generation RULES:
  # We consider that the cluster is in a 1-Gb/s network and we set the packet size as 1000 bytes
  # Googling(http://www.cisco.com/web/about/security/intelligence/network_performance_metrics.html) 
  # we found that this bandwith has a packet_per_sec rate of 1.000.000 p/s
  
  pkt.sec <- filter(rpois(trace.size, 1000000), filter=rep(1, min(trace.size, 5)), circular=TRUE)
  
  if (length(pkt.sec) > 1 & min(pkt.sec) < 0){
    # Normalize to minimum 0
    pkt.sec <- pkt.sec + (min(pkt.sec) * -1)
  }
  
  # Generate the Fail Metrics
  pkt.sec <- GenerateFailMetrics(pkt.sec, num.fail.metrics)
  
  return(round(pkt.sec, round.digits))
}

# ------------------------------------------------------------------------------
# DISK Functions
# ------------------------------------------------------------------------------
DISK_UTIL <- function(trace.size, population.data, num.fail.metrics){
  # DISK_UTIL: Disk bandwidth utilization in MB/s (10^6 bytes, megabytes per second)
  
  # Generation RULE:
  # Time-serie with randon poisson (lambda = 2000) data 
  disk.util <- filter(rpois(trace.size, 2000), filter=rep(1, min(trace.size, 5)), circular=TRUE)
  
  if (length(disk.util) > 1){
    # Normalize to minimum 0
    if (min(disk.util) < 0){
      disk.util <- disk.util + min(disk.util) * -1
    }else{
      disk.util <- disk.util + min(disk.util)
    }
    
    # Change the scale to Mega-bytes
    disk.util <- disk.util/10^6
  }
  
  # Generate the Fail Metrics
  disk.util <- GenerateFailMetrics(disk.util, num.fail.metrics)
  
  return(round(disk.util, round.digits))
}
IOS_PER_SEC <- function(trace.size, population.data, num.fail.metrics){
  # IOS_PER_SEC: The number of disk I/O operations executed per second.
  # Based on the sample trace data from Evandro
  ios.sec <- jitter(filter(rpois(trace.size, 2), filter=rep(1, min(trace.size, 5)), circular=TRUE))
  
  if (length(ios.sec) > 1 & min(ios.sec) < 0){
    # Normalize to minimum 0
    ios.sec <- ios.sec + (min(ios.sec) * -1)
  }
  
  # Generate the Fail Metrics
  ios.sec <- GenerateFailMetrics(ios.sec, num.fail.metrics)
  
  return(round(ios.sec, round.digits))
}

# ------------------------------------------------------------------------------
# CPU Functions
# ------------------------------------------------------------------------------
CPU_UTIL <- function(trace.size, population.data, num.fail.metrics){
  # Remove the NAs
  population.data <- population.data[!is.na(population.data)]

  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  cpu.util <- jitter(population.data[1:trace.size])
  
  # Check the 0-1 boundaries
  cpu.util <- (cpu.util - min(cpu.util))/(max(cpu.util) - min(cpu.util))
  
  # Generate the Fail Metrics
  cpu.util <- GenerateFailMetrics(cpu.util, num.fail.metrics)
  
  return(round(cpu.util, round.digits))
}
CPU_ALLOC <- function(trace.size, population.data, num.fail.metrics){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  
  # Generate the Fail Metrics
  population.data <- GenerateFailMetrics(population.data, num.fail.metrics)
  
  return(population.data[1:trace.size])
}
CPU_QUEUE <- function(trace.size, population.data, num.fail.metrics, cpu.util, cpu.alloc){
  # Generation RULE:
  # If the as.integer(cpu.util) is higher than 90, the CPU_QUEUE is equal to (as.integer(cpu.util) - 90).
  cpu.queue <- as.integer((cpu.util/cpu.alloc) * 100)
  cpu.queue[cpu.queue < 90] <- 0
  cpu.queue[cpu.queue > 90 & !is.na(cpu.queue)] <- cpu.queue[cpu.queue > 90 & !is.na(cpu.queue)] - 90
  
  # Generate the Fail Metrics (All NAs from cpu.util and cpu.alloc will appear here too...)
  cpu.queue <- GenerateFailMetrics(cpu.queue, num.fail.metrics)
  
  return(cpu.queue)
}

# ------------------------------------------------------------------------------
# MEMORY Functions
# ------------------------------------------------------------------------------
MEM_UTIL <- function(trace.size, population.data, num.fail.metrics){
  # Remove the NAs
  population.data <- population.data[!is.na(population.data)]

  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  mem.util = jitter(population.data[1:trace.size])
  
  # Check the 0-1 boundaries
  mem.util <- (mem.util - min(mem.util))/(max(mem.util) - min(mem.util))
  
  # Generate the Fail Metrics
  GenerateFailMetrics(mem.util, num.fail.metrics)
  
  return(round(mem.util, round.digits))
}
MEM_ALLOC <- function(trace.size, population.data, num.fail.metrics){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  
  # Generate the Fail Metrics
  GenerateFailMetrics(population.data, num.fail.metrics)
  
  return(population.data[1:trace.size])
}
PAGES_PER_SEC <- function(trace.size, population.data, num.fail.metrics){
  # Generation RULE:
  # Jittered Time-serie with randon poisson (lambda = 10) data 
  pages.sec <- jitter(filter(rpois(trace.size, 1), filter=rep(1, min(trace.size, 5)), circular=TRUE))
  
  # Generate the Fail Metrics
  GenerateFailMetrics(pages.sec, num.fail.metrics)

  return(round(pages.sec, round.digits))
}

# ------------------------------------------------------------------------------
# Fail Metrics Functions
# ------------------------------------------------------------------------------
GenerateFailMetrics <- function(data.vector, num.fail.metrics){
  if (num.fail.metrics > sum(is.na(data.vector))){
    num.fail.metrics <- num.fail.metrics - sum(is.na(data.vector))
    data.vector[sample(which(!is.na(data.vector)), num.fail.metrics)] <- rep(NA, num.fail.metrics)
  }
  return(data.vector)
}

# =============================================================================
# MAIN
# =============================================================================
args <- commandArgs(trailingOnly = TRUE)

# Input Arguments
traces.dir <- args[1]                       # "data/traces/"
output.dir <- args[2]                       # "data/output/"
initial.vm <- as.integer(args[3])           # 1 (for example)
final.vm <- as.integer(args[4])             # 100 (for example)
perc.fail.collect <- as.numeric(args[5])    # 0.01 (for example)
perc.fail.metric <- as.numeric(args[6])     # 0.05 (for example)

# Test Arguments
# traces.dir <- "data/traces/"
# output.dir <- "data/output/"
# initial.vm <- 1
# final.vm <- 2
# perc.fail.collect <- 0.01
# perc.fail.metric <- 0.05

# Fixed Input Arguments
min.trace.size <- 105120 # Evandro's Requirement: (60/5) * 24 * 365 * 1 (1 year in minutes) = 105120
max.trace.size <- 315360 # Evandro's Requirement: (60/5) * 24 * 365 * 3 (3 year in minutes) = 315360
round.digits <- 5
first.start.time <- 1199145600 # 01/01/2008
last.start.time <- 1262304000  # 01/01/2010 (the last possible time will be at 01/01/2013)

# Output directory creation
dir.create(output.dir, showWarnings=F)

# Temp variables
file.index <- 1
curr.file.rows <- 0
max.file.rows <- 10000000 # MAX = 10 million rows (50 vm's per file on average, 220 MB on average)
base.trace.files <- paste(traces.dir, list.files(traces.dir), sep ="")

# Create the TIME table
cat("Creating the TIME table...\n")
time.table <- data.frame(date_time=DATE_TIME(first.start.time, last.start.time, max.trace.size))
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
                            net_util=NET_UTIL(trace.size, base.trace$NET_UTIL, num.fail.metrics),
                            pkt_per_sec=PKT_PER_SEC(trace.size, NA, num.fail.metrics),
                            disk_util=DISK_UTIL(trace.size, NA, num.fail.metrics),
                            ios_per_sec=IOS_PER_SEC(trace.size, NA, num.fail.metrics),
                            cpu_util=CPU_UTIL(trace.size, base.trace$CPU_UTIL/base.trace$CPU_ALLOC, num.fail.metrics),
                            cpu_alloc=CPU_ALLOC(trace.size, base.trace$CPU_ALLOC, num.fail.metrics),
                            cpu_queue=rep(0.0, trace.size),
                            memory_util=MEM_UTIL(trace.size, base.trace$MEM_UTIL/base.trace$MEM_ALLOC, num.fail.metrics),
                            memory_alloc=MEM_ALLOC(trace.size, base.trace$MEM_ALLOC, num.fail.metrics),
                            pages_per_sec=PAGES_PER_SEC(trace.size, NA, num.fail.metrics))
  
  trace.table$cpu_queue <- CPU_QUEUE(trace.size, NA, num.fail.metrics,
                                     trace.table$cpu_util, trace.table$cpu_alloc)
  
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

# TODO (Add a daily and weekly pattern then!)
