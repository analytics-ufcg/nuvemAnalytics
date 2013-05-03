rm(list =ls())

# =============================================================================
# FUNCTIONS
# =============================================================================

# ------------------------------------------------------------------------------
# TIME Functions
# ------------------------------------------------------------------------------
CriarDATE_TIME <- function(trace.size, population.data){
  # Starts in 01/01/2010 
  start.time <- 1262304000
  date.time <- seq(from=start.time, to=(start.time + (trace.size-1) * 300), by=300)
  return(as.POSIXct(date.time, origin = "1970-01-01"))
}

# ------------------------------------------------------------------------------
# NETWORK Functions
# ------------------------------------------------------------------------------
CriarNET_UTIL <- function(trace.size, population.data){
  net.util = filter(rnorm(trace.size, 0, 1), filter=seq_len(min(length(trace.size), 5)), 
                    circular=TRUE)
  if (length(net.util) > 1){
    net.util <- (net.util - min(net.util))/(max(net.util)-min(net.util))
  }
  return(round(net.util, round.digits))
}
CriarPKT_PER_SEC <- function(trace.size, population.data){
  pkt.sec = runif(trace.size, 0, 20)
  return(round(pkt.sec, round.digits))
}

# ------------------------------------------------------------------------------
# DISK Functions
# ------------------------------------------------------------------------------
CriarDISK_UTIL <- function(trace.size, population.data){
  disk.util = filter(rnorm(trace.size, 0, 1), filter=seq_len(min(length(trace.size), 5)), 
                     circular=TRUE)
  if (length(disk.util) > 1){
    disk.util <- (disk.util - min(disk.util))/(max(disk.util)-min(disk.util))
  }
  return(round(disk.util, round.digits))
}
CriarIOS_PER_SEC <- function(trace.size, population.data){
  ios.sec = runif(trace.size, 0, 20)
  return(round(ios.sec, round.digits))
}

# ------------------------------------------------------------------------------
# CPU Functions
# ------------------------------------------------------------------------------
CriarCPU_UTIL <- function(trace.size, population.data){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  cpu.util = jitter(population.data[1:trace.size])
  return(round(cpu.util, round.digits))
}
CriarCPU_ALLOC <- function(trace.size, population.data){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  return(population.data[1:trace.size])
}
CriarCPU_QUEUE <- function(trace.size, population.data){
  cpu.queue = rep(0, trace.size)
  return(cpu.queue)
}

# ------------------------------------------------------------------------------
# MEMORY Functions
# ------------------------------------------------------------------------------
CriarMEM_UTIL <- function(trace.size, population.data){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  mem.util = jitter(population.data[1:trace.size])
  return(round(mem.util, round.digits))
}
CriarMEM_ALLOC <- function(trace.size, population.data){
  if (trace.size > length(population.data)){
    population.data <- rep(population.data, ceiling(trace.size/length(population.data)))
  }
  return(population.data[1:trace.size])
}
CriarPAGES_PER_SEC <- function(trace.size, population.data){
  pages.sec = runif(trace.size, 0, 20)
  return(round(pages.sec, round.digits))
}

# GENERAL Functions
CriarPK <- function(trace.size){
  return(seq_len(trace.size))
}

# =============================================================================
# MAIN
# =============================================================================
args <- commandArgs(trailingOnly = TRUE)

# Input Arguments
traces.dir <- args[1]             # "data/traces/"
output.dir <- args[2]             # "data/output/"
initial.vm <- as.integer(args[3]) # 1 (for example)
final.vm <- as.integer(args[4])   # 100 (for example)

# Fixed Input Arguments
min.trace.size <- 105120 # Evandro's Requirement: (60/5) * 24 * 365 * 1 (1 year in minutes) = 105120
max.trace.size <- 315360 # Evandro's Requirement: (60/5) * 24 * 365 * 3 (3 year in minutes) = 315360
round.digits <- 6

# Output directory creation
dir.create(output.dir, showWarnings=F)

# Temp variables
file.index <- 1
curr.file.rows <- 0
max.file.rows <- 10000000 # MAX = 10 million rows (50 vm's per file on average)
base.trace.files <- paste(traces.dir, list.files(traces.dir), sep ="")

# Create the TIME table
id.time <- CriarPK(max.trace.size)
time.table <- data.frame(id_time=id.time,
                         date_time=CriarDATE_TIME(max.trace.size))

for (vm in seq(initial.vm, final.vm)){
  trace.size <- sample(seq(from=min.trace.size, to=max.trace.size), 1) 
  cat("VM:", vm, "- Trace size:", trace.size, "\n")
  
  base.trace <- read.csv(base.trace.files[(vm %% length(base.trace.files)) + 1])
  
  vm.table <- data.frame(id_vm=vm,
                         vm_name=paste("VM_", vm, sep = ""))
  
  network.table <- data.frame(id_time=id.time[seq_len(trace.size)], 
                              id_vm=rep(vm, trace.size),
                              net_util=CriarNET_UTIL(trace.size, base.trace$NET_UTIL),
                              pkt_per_sec=CriarPKT_PER_SEC(trace.size, NA))
  
  disk.table <- data.frame(id_time=id.time[seq_len(trace.size)], 
                           id_vm=rep(vm, trace.size),
                           disk_util=CriarDISK_UTIL(trace.size),
                           ios_per_sec=CriarIOS_PER_SEC(trace.size, NA))
  
  cpu.table <- data.frame(id_time=id.time[seq_len(trace.size)], 
                          id_vm=rep(vm, trace.size),
                          cpu_util=CriarCPU_UTIL(trace.size, base.trace$CPU_UTIL/base.trace$CPU_ALLOC),
                          cpu_alloc=CriarCPU_ALLOC(trace.size, base.trace$CPU_ALLOC),
                          cpu_queue=CriarCPU_QUEUE(trace.size, NA))
  
  memory.table <- data.frame(id_time=id.time[seq_len(trace.size)], 
                             id_vm=rep(vm, trace.size),
                             memory_util=CriarMEM_UTIL(trace.size, base.trace$MEM_UTIL/base.trace$MEM_ALLOC),
                             memory_alloc=CriarMEM_ALLOC(trace.size, base.trace$MEM_ALLOC),
                             pages_sec=CriarPAGES_PER_SEC(trace.size, NA))
  
  # Write tables (the vm file is unique)
  write.table(vm.table, paste(output.dir, "vm.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  
  write.table(network.table, paste(output.dir, "network_", file.index,".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(disk.table, paste(output.dir, "disk_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(cpu.table, paste(output.dir, "cpu_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(memory.table, paste(output.dir, "memory_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  
  curr.file.rows = curr.file.rows + trace.size
  if (curr.file.rows >= max.file.rows){
    file.index <- file.index + 1
    curr.file.rows <- 0
  }
}

# Write the TIME table to FILE
# Check if the time table already exists, only write if there isnt
time.table.file <- paste(output.dir, "time.csv", sep = "")
if (!file.exists(time.table.file)){
  write.table(time.table, time.table.file, col.names = F, row.names=F, sep = ",")
}

# Duvidas: 
#   Todos os tempos podem iniciar do mesmo instante, ou devem iniciar em momentos diferentes? 
