over_memory <- function(x){
	
	dff	<- data.frame(id_vm=x[,1], vm_name=x[,2], mem_util=x[,3], mem_alloc=x[,4], timestamp=x[,5])
	init_date	<- x[,6]
	end_date	<- x[,7]
	target_util	<- x[,8]
	target_alloc	<- x[,9]

	dff	<- subset(dff, (timestamp >= init_date) & (timestamp <= end_date))

	df_max	<- aggregate(mem_util ~ ., data=data.frame(id_vm=dff$id_vm, mem_util=dff$mem_util), FUN=max)	

	dff	<- subset(dff, (id_vm %in% df_max$id_vm) & (mem_util %in% df_max$mem_util))
	dff	<- subset(dff, (mem_util < target_util) & (mem_alloc > target_alloc))
	
	result	<- data.frame(vm_name=dff$vm_name, mem_util=dff$mem_util, mem_alloc=dff$mem_alloc)
	result	<- result[!is.na(result[,2]),]

	result	<- result[with(result, order(mem_util)),]
	result
}

VMOverMemoryFuncFactory <- function(){
	list(name=over_memory ,udxtype=c("transform"),intype=c("int", "varchar", "float","float","timestamp", "timestamp","timestamp","numeric","numeric"), outtype=c("varchar", "float", "float"), outnames=c("vm_name", "mem_util", "mem_alloc"))
}

