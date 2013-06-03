LowUsageVMsFunc <- function(x){
  q1 <- quantile(x[,2], x[1,3], na.rm = T)
  limiar1 <- x[1,4]
  df <- x[x[,2] >= q1 & x[,2] < limiar1 , 1:2]
  df <- df[!is.na(df[,2]),]
  return (df)
}

LowUsageVMsFuncFactory <- function(){
 list(name=LowUsageVMsFunc, udxtype=c("transform"), intype=c("int", rep("float",3)), outtype=c("int", rep("float",1)), outnames=c("id_vm", "col1"))
}

LowUsageVMsWithTimeFunc <- function(x){
  q1 <- quantile(x[,2], x[1,3], na.rm = T)
  limiar1 <- x[1,4]
  df <- x[x[,2] >= q1 & x[,2] < limiar1 , c(1:2, 5)]
  df <- df[!is.na(df[,2]),]
  return (df)
}

LowUsageVMsWithTimeFuncFactory <- function(){
 list(name=LowUsageVMsWithTimeFunc, udxtype=c("transform"), intype=c("int", rep("float",3), "int"), outtype=c("int", rep("float",1), "int"), outnames=c("id_vm", "col1", "id_time"))
}   



