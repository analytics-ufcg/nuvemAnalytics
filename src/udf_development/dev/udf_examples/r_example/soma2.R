soma2 <- function(x){
     df = x
     df[,1] = sum(df[,1])
     df
}

somaFactory <- function(){
   list(name=soma2, udxtype=c("scalar"),intype=c("int"),outtype=c("int"))
}
