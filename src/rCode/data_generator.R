rm(list =ls())

# =============================================================================
# FUNCTIONS
# =============================================================================

# ------------------------------------------------------------------------------
# TIME Functions
# ------------------------------------------------------------------------------
CriarDATE_TIME <- function(trace.size){
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
  return(net.util)
}
CriarPKT_PER_SEC <- function(trace.size, population.data){
  pkt.sec = rnorm(trace.size, 0, 20)
  return(pkt.sec)
}

# ------------------------------------------------------------------------------
# DISK Functions
# ------------------------------------------------------------------------------
CriarDISK_UTIL <- function(trace.size){
  disk.util = filter(rnorm(trace.size, 0, 1), filter=seq_len(min(length(trace.size), 5)), 
                     circular=TRUE)
  disk.util <- (disk.util - min(disk.util))/(max(disk.util)-min(disk.util))
  return(disk.util)
}
CriarIOS_PER_SEC <- function(trace.size, population.data){
  ios.sec = runif(trace.size, 0, 20)
  return(ios.sec)
}

# ------------------------------------------------------------------------------
# CPU Functions
# ------------------------------------------------------------------------------
CriarCPU_UTIL <- function(trace.size, population.data){
  cpu.util = jitter(population.data[1:trace.size])
  return(cpu.util)
}
CriarCPU_ALLOC <- function(trace.size, population.data){
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
  mem.util = jitter(population.data[1:trace.size])
  return(mem.util)
}
CriarMEM_ALLOC <- function(trace.size, population.data){
  return(population.data[1:trace.size])
}
CriarPAGES_PER_SEC <- function(trace.size, population.data){
  pages.sec = runif(trace.size, 0, 20)
  return(pages.sec)
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
output.dir <- "data/output/"
traces.dir <- "data/traces/"
dir.create(output.dir, showWarnings=F)
base.traces <- paste(traces.dir, list.files(traces.dir), sep ="")

trace.size <- 10
num.vms <- 2

# Create the TIME table
id.time <- CriarPK(trace.size)
time.table <- data.frame(id_time=id.time,
                         date_time=CriarDATE_TIME(trace.size))

for (vm in seq_len(num.vms)){
  base.trace <- read.csv(base.traces[vm %% length(base.traces)])
  id.tables <- seq(trace.size * (vm-1) + 1, trace.size * vm, 1)

  vm.table <- data.frame(id_vm=vm,
                         vm_name=paste("VM_", vm, sep = ""))
                           
  network.table <- data.frame(id_net=id.tables,
                              id_time=id.time, 
                              id_vm=rep(vm, trace.size),
                              net_util=CriarNET_UTIL(trace.size, base.trace$NET_UTIL),
                              pkt_per_sec=CriarPKT_PER_SEC(trace.size, NA))
  
  disk.table <- data.frame(id_disk=id.tables,
                           id_time=id.time, 
                           id_vm=rep(vm, trace.size),
                           disk_util=CriarDISK_UTIL(trace.size),
                           ios_per_sec=CriarIOS_PER_SEC(trace.size, NA))
  
  cpu.table <- data.frame(id_cpu=id.tables,
                          id_time=id.time,
                          id_vm=rep(vm, trace.size),
                          cpu_util=CriarCPU_UTIL(trace.size, base.trace$CPU_UTIL/base.trace$CPU_ALLOC),
                          cpu_alloc=CriarCPU_ALLOC(trace.size, base.trace$CPU_ALLOC),
                          cpu_queue=CriarCPU_QUEUE(trace.size, NA),
                          cpu_grow_rate=CriarCPU_GROWRATE(trace.size, NA),
                          cpu_headroom=CriarCPU_HEADROOM(trace.size, NA))
  
  memory.table <- data.frame(id_mem=id.tables,
                             id_time=id.time, 
                             id_vm=rep(vm, trace.size),
                             memory_util=CriarMEM_UTIL(trace.size, base.trace$MEM_UTIL/base.trace$MEM_ALLOC),
                             memory_alloc=CriarMEM_ALLOC(trace.size, base.trace$MEM_ALLOC),
                             pages_sec=CriarPAGES_PER_SEC(trace.size, NA))
  
  other.table <- data.frame(id_other=id.tables,
                            id_time=id.time, 
                            id_vm=rep(vm, trace.size),
                            mem_headroom=CriarMEM_HEADROOM(trace.size, NA),
                            disk_io_headroom=CriarDISK_IO_HEADROOM(trace.size, NA),
                            mem_io_headroom=CriarNET_IO_HEADROOM(trace.size, NA),
                            five_star=CriarFIVE_STAR(trace.size, NA),
                            minutes_sustained=CriarMINUTES_SUSTAINED(trace.size, NA))
  
  write.table(vm.table, paste(output.dir, "vm.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(network.table, paste(output.dir, "network.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(disk.table, paste(output.dir, "disk.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(cpu.table, paste(output.dir, "cpu.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(memory.table, paste(output.dir, "memory.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(other.table, paste(output.dir, "other.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
}

write.table(time.table, paste(output.dir, "time.csv", sep = ""), col.names = F, row.names=F, sep = ",")
