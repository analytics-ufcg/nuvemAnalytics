divisao <- function(x){
    df <- data.frame(x[,1]/x[,2])
    df
}

divisaoFactory <- function(){
    list(name=divisao,udxtype=c("transform"),intype=c("float","float"),outtype=c("float"))
}
