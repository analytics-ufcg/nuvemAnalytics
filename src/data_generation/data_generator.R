rm(list =ls())

CriarDATE_TIME <- function(tam, population.data){
  if (tam > length(population.data)){
    last.time <- population.data[length(population.data)]
    extra.rows <- tam - length(population.data)
    extra <- seq(from=last.time + 300, to=(last.time + extra.rows * 300), by=300)
    return(c(population.data, extra))
  }else{
    return(population.data[1:tam])
  }
}

CriarCPU_UTIL <- function(tam, population.data){
  n.cpu.util = population.data[1:tam] * runif(tam, 0, 1)
  return(n.cpu.util)
}

CriarMEM_UTIL <- function(tam, population.data){
  n.mem.util = population.data[1:tam] * runif(tam, 0, 1)
  return(n.mem.util)
}

CriarNET_UTIL <- function(tam, population.data){
  n.net.util = runif(tam, 0, 1)
  return(n.net.util)
}

CriarDISK_UTIL <- function(tam, population.data){
  n.disk.util = population.data[1:tam] * runif(tam, 0, 1)
  return(n.disk.util)
}

CriarCPU_ALLOC <- function(tam, population.data){
  return(population.data[1:tam])
}

CriarMEM_ALLOC <- function(tam, population.data){
  return(population.data[1:tam])
}

CriarCPU_QUEUE <- function(tam, population.data){
  n.cpu.queue = rep(0, tam)
  return(n.cpu.queue)
}

CriarPAGES_PER_SEC <- function(tam, population.data){
  n.pages.sec = runif(tam, 0, 20)
  return(n.pages.sec)
}

CriarIOS_PER_SEC <- function(tam, population.data){
  ios.sec = runif(tam, 0, 20)
  return(ios.sec)
}

CriarPKT_PER_SEC <- function(tam, population.data){
  pkt.sec = runif(tam, 0, 20)
  return(pkt.sec)
}

CriarPK <- function(start, tam){
  return((start+1):(start + tam))
}

tam = 10
output.dir <- "data/output/"
traces.dir <- "data/traces/"
dir.create(output.dir, showWarnings=F)
last.id.time <- 0

for (trace in list.files(traces.dir)[1:2]){
  df.origem = read.csv(paste(traces.dir, trace, sep=""))
  
  id.time <- CriarPK(last.id.time, tam)
  
  time.table <- data.frame(id_time=id.time,
                           date_time=CriarDATE_TIME(tam, df.origem$UTIS))
  
  cpu.table <- data.frame(id_time=id.time, 
                          cpu_util=CriarCPU_UTIL(tam, df.origem$CPU_UTIL),
                          cpu_alloc=CriarCPU_ALLOC(tam, df.origem$CPU_ALLOC),
                          cpu_queue=CriarCPU_QUEUE(tam, NA))
  
  memory.table <- data.frame(id_time=id.time, 
                             memory_util=CriarMEM_UTIL(tam, df.origem$MEM_UTIL),
                             memory_alloc=CriarMEM_ALLOC(tam, df.origem$MEM_ALLOC),
                             pages_sec=CriarPAGES_PER_SEC(tam, NA))
  
  disk.table <- data.frame(id_time=id.time, 
                           disk_util=CriarDISK_UTIL(tam, df.origem$DISK_UTIL),
                           ios_per_sec=CriarIOS_PER_SEC(tam, NA))
  
  network.table <- data.frame(id_time=id.time, 
                              net_util=CriarNET_UTIL(tam, df.origem$NET_UTIL),
                              pkt_per_sec=CriarPKT_PER_SEC(tam, NA))
  
  
  write.table(time.table, paste(output.dir, "time.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(cpu.table, paste(output.dir, "cpu.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(memory.table, paste(output.dir, "memory.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(disk.table, paste(output.dir, "disk.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  write.table(network.table, paste(output.dir, "network.csv", sep = ""), col.names = F, row.names=F, append = T, sep = ",")
  
  last.id.time <- id.time[length(id.time)]
  
}