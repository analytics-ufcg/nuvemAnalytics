rm(list =ls())

# =============================================================================
# FUNCTIONS
# =============================================================================

# ------------------------------------------------------------------------------
# TIME Functions
# ------------------------------------------------------------------------------
CriarDATE_TIME <- function(trace.size, population.data){
  # YYYYMMDDhhmm: 201105161615
  start.time <- 1305580500
  date.time <- seq(from=start.time, to=(start.time + (trace.size-1) * 300), by=300)
  return(date.time)
}

# ------------------------------------------------------------------------------
# NETWORK Functions
# ------------------------------------------------------------------------------
CriarNET_UTIL <- function(trace.size, population.data){
  net.util = filter(rnorm(trace.size, 0, 1), filter=seq_len(min(length(trace.size), 5)), 
                     circular=TRUE)
  net.util <- (net.util - min(net.util))/(max(net.util)-min(net.util))
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
  disk.util <- (disk.util - min(disk.util))/(max(disk.util)-min(disk.util))
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
CriarCPU_GROWRATE <- function(trace.size, population.data){
  cpu.gr = rep(0, trace.size)
  return(cpu.gr)
}
CriarCPU_HEADROOM <- function(trace.size, population.data){
  cpu.head = rep(0, trace.size)
  return(cpu.head)
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
  return(population.data[1:trace.size])
}
CriarPAGES_PER_SEC <- function(trace.size, population.data){
  pages.sec = runif(trace.size, 0, 20)
  return(round(pages.sec, round.digits))
}

# ------------------------------------------------------------------------------
# OTHER Function
# ------------------------------------------------------------------------------
CriarMEM_HEADROOM <- function(trace.size, population.data){
  mem.head = rep(0, trace.size)
  return(mem.head)
}
CriarDISK_IO_HEADROOM <- function(trace.size, population.data){
  disk.head = rep(0, trace.size)
  return(disk.head)
}
CriarNET_IO_HEADROOM <- function(trace.size, population.data){
  net.head = rep(0, trace.size)
  return(net.head)
}
CriarFIVE_STAR <- function(trace.size, population.data){
  five = rep(0, trace.size)
  return(five)
}
CriarMINUTES_SUSTAINED <- function(trace.size, population.data){
  minutes = rep(0, trace.size)
  return(minutes)
}


# GENERAL Functions
CriarPK <- function(trace.size){
  return(seq_len(trace.size))
}

# =============================================================================
# MAIN
# =============================================================================
# Input Arguments
traces.dir <- "data/traces/"
output.dir <- "data/output/"
num.vms <- 100
min.trace.size <- 105120 # Evandro's Requirement: (60/5) * 24 * 365 * 1 (1 year in minutes) = 105120
max.trace.size <- 315360 # Evandro's Requirement: (60/5) * 24 * 365 * 3 (3 year in minutes) = 315360
round.digits <- 6

# Output directory creation
dir.create(output.dir, showWarnings=F)

# Temp variables
file.index <- 1
curr.file.rows <- 0
max.file.rows <- 5000000 # MAX = 5 million rows (24 vm's per file on average)
base.trace.files <- paste(traces.dir, list.files(traces.dir), sep ="")
id.tables <- c(0)

# Create the TIME table
id.time <- CriarPK(max.trace.size)
time.table <- data.frame(id_time=id.time,
                         date_time=CriarDATE_TIME(max.trace.size))

for (vm in seq_len(num.vms)){
  trace.size <- sample(seq(from=min.trace.size, to=max.trace.size), 1) 
  cat("VM:", vm, "- Trace size:", trace.size, "\n")
  
  base.trace <- read.csv(base.trace.files[vm %% length(base.trace.files)])
  last.id.tables <- id.tables[length(id.tables)]
  id.tables <- seq(last.id.tables + 1, last.id.tables + trace.size, 1)

  vm.table <- data.frame(id_vm=vm,
                         vm_name=paste("VM_", vm, sep = ""))
                           
  network.table <- data.frame(id_net=id.tables,
                              id_time=id.time[seq_len(trace.size)], 
                              id_vm=rep(vm, trace.size),
                              net_util=CriarNET_UTIL(trace.size, base.trace$NET_UTIL),
                              pkt_per_sec=CriarPKT_PER_SEC(trace.size, NA))
  
  disk.table <- data.frame(id_disk=id.tables,
                           id_time=id.time[seq_len(trace.size)], 
                           id_vm=rep(vm, trace.size),
                           disk_util=CriarDISK_UTIL(trace.size),
                           ios_per_sec=CriarIOS_PER_SEC(trace.size, NA))
  
  cpu.table <- data.frame(id_cpu=id.tables,
                          id_time=id.time[seq_len(trace.size)], 
                          id_vm=rep(vm, trace.size),
                          cpu_util=CriarCPU_UTIL(trace.size, base.trace$CPU_UTIL/base.trace$CPU_ALLOC),
                          cpu_alloc=CriarCPU_ALLOC(trace.size, base.trace$CPU_ALLOC),
                          cpu_queue=CriarCPU_QUEUE(trace.size, NA),
                          cpu_grow_rate=CriarCPU_GROWRATE(trace.size, NA),
                          cpu_headroom=CriarCPU_HEADROOM(trace.size, NA))
  
  memory.table <- data.frame(id_mem=id.tables,
                             id_time=id.time[seq_len(trace.size)], 
                             id_vm=rep(vm, trace.size),
                             memory_util=CriarMEM_UTIL(trace.size, base.trace$MEM_UTIL/base.trace$MEM_ALLOC),
                             memory_alloc=CriarMEM_ALLOC(trace.size, base.trace$MEM_ALLOC),
                             pages_sec=CriarPAGES_PER_SEC(trace.size, NA))
  
  other.table <- data.frame(id_other=id.tables,
                            id_time=id.time[seq_len(trace.size)], 
                            id_vm=rep(vm, trace.size),
                            mem_headroom=CriarMEM_HEADROOM(trace.size, NA),
                            disk_io_headroom=CriarDISK_IO_HEADROOM(trace.size, NA),
                            mem_io_headroom=CriarNET_IO_HEADROOM(trace.size, NA),
                            five_star=CriarFIVE_STAR(trace.size, NA),
                            minutes_sustained=CriarMINUTES_SUSTAINED(trace.size, NA))

  # Write tables (the vm file is unique)
  write.table(vm.table, paste(output.dir, "vm.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  
  write.table(network.table, paste(output.dir, "network_", file.index,".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(disk.table, paste(output.dir, "disk_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(cpu.table, paste(output.dir, "cpu_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(memory.table, paste(output.dir, "memory_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(other.table, paste(output.dir, "other_", file.index, ".csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  
  curr.file.rows = curr.file.rows + trace.size
  if (curr.file.rows >= max.file.rows){
    file.index <- file.index + 1
    curr.file.rows <- 0
  }
}

write.table(time.table, paste(output.dir, "time.csv", sep = ""), col.names = F, row.names=F, sep = ",")

# Duvidas: 
#   Todos os tempos podem iniciar do mesmo instante, ou devem iniciar em momentos diferentes? 
#   Como calcular as métricas cruas derivadas.
