var selectedBubble = null;
var metric_list = null;
var table_list = null;
var ts_jquery = null;
var ts_jquery2 = null;
var zoomToBubble = null;

var start_date_all_ts = null;
var end_date_all_ts = null;
var start_date_ts = null;
var end_date_ts = null;

function changeTimeSeries(operator){
	// 30 days change (before or after operator)
       	if (selectedBubble != null){
        	if(selectedBubble.type == "vm"){

			var query = "change_time_series?ts_operator=" + operator;

			removeTimeSeries();
			$("#metric_time_series").html("<br><img src='static/img/ajax-loader.gif'></img>");
			ts_jquery2 = $.get(query, function(data){
				data = JSON.parse(data);	
				if (data.ts.length > 0){
					start_date_ts = Date.parse(data.ts[0].date);
					end_date_ts = Date.parse(data.ts[data.ts.length-1].date);
					$("#metric_time_series").html("");
					showTimeSeries(data.ts);
				}else{
					// This should never occur (the button should be disabled)
					$("#metric_time_seroes").html("No data in this interval.");
				}
			});
              }else{
                        if (ts_jquery2 != null){
                                ts_jquery2.abort();
                                ts_jquery2 = null;
                        }
                        removeTimeSeries();
                }
        }else{
                if (ts_jquery2 != null){
                        ts_jquery2.abort();
                        ts_jquery2 = null;
                }

                removeTimeSeries();
        }
}

function pad(number){
        return (number<10) ? ("0" + number) : number;
}

function updateTimeSeries(){
	if (selectedBubble != null){
		if(selectedBubble.type == "vm"){
        		// Prepare the query 
        	        var query = "metric_time_series?vm_name=" + selectedBubble.name;
                	var selected_index = document.getElementById("metric_type_vm").selectedIndex;
			query += "&metric=" + metric_list[selected_index];
			query += "&table=" + table_list[selected_index];

                        query += "&start_date=" + selectedBubble.parent.parent.start_date;
			query += "&end_date=" + selectedBubble.parent.parent.end_date;
	        	removeTimeSeries();
			
			$("#metric_time_series").html("<br><img src='static/img/ajax-loader.gif'></img>");
			ts_jquery = $.get(query, function(data){
        	              	data = JSON.parse(data);
				if (data.ts.length > 0){
        	                        start_date_ts = Date.parse(data.ts[0].date);
	                                end_date_ts = Date.parse(data.ts[data.ts.length-1].date);
					start_date_all_ts = Date.parse(data.first_date);
					end_date_all_ts = Date.parse(data.last_date);

		                	$("#metric_time_series").html("");
        	                        showTimeSeries(data.ts);
				}else{
					$("#metric_time_series").html("No data in this interval.");
				}
        	      	});
        	}else{
			if (ts_jquery != null){
				ts_jquery.abort();
				ts_jquery = null;
			}
			removeTimeSeries();
		}
	}else{
		if (ts_jquery != null){
                	ts_jquery.abort();
                        ts_jquery = null;
                }

		removeTimeSeries();
	}
}

function showTimeSeriesChart(bubble){

	metric_list = null;
	table_list = null;
	$("#metric_type_vm").empty();
	$("#metric_type_vm").hide();
	$("#time_series_pagination").hide();

	var div_text = "";
	
	if(bubble != null){	
		if(bubble.type == "vm"){
			// Call the server to get the metrics and tables
			$.get("query_metrics?query_list=" + bubble.parent.id, function (data){
							
				data = JSON.parse(data);
				metric_list = data.metrics;
				table_list = data.tables;

				$("#metric_type_vm").show();
				$("#time_series_pagination").show();

		    		for(var i = 0; i < metric_list.length; i++){
	       				var t = document.createElement("option")
	       				t.value = metric_list[i];
       					t.text = metric_list[i];
       					$("#metric_type_vm").append(t);
	   	    		}
				// This call occurs only when the query returns (asynchronous query)
				updateTimeSeries();
			});
			
		}else{
			div_text += "Please select a VM.";
			updateTimeSeries();
		}
	}else{
		div_text += "Please select a VM."
 		updateTimeSeries();
	}
	$("#metric_time_series").html(div_text);
}	

function showQueryResultParallelCoord(bubble){
        if ( bubble != null ){
                var data = [];
                if (bubble.type == "vm_set"){
			removeParallelCoord();
                        // Select the queries and the columns
                        var queries = bubble.query_names;
                        var col_names = new Array();
                        for (var i = 0; i < queries.length; i++){
                                query = queries[i];
                                for (var j = 0; j < bubble.query_columns[query].length; j++){
                                        col_names[col_names.length] = bubble.query_columns[query][j];
                                }
                        }

                        var data = [];

                        for (var j = 0; j < bubble.children.length; j++){
                                var vm_data = {name : bubble.children[j].name};
                                for (var i = 0; i < col_names.length; i++){
                                        vm_data[col_names[i]] = String(bubble.children[j].values[i]);
                                }
                                data.push(vm_data);
                        }
			$("#query_result_parallel_coord").html("");
			showParallelCoord(data);

                }
                if (bubble.type == "vm"){
			removeParallelCoord();
                        var queries = bubble.parent.query_names;
                        var col_names = new Array();
                        for (var i = 0; i < queries.length; i++){
                                query = queries[i];
                                for (var j = 0; j < bubble.parent.query_columns[query].length; j++){
                                        col_names[col_names.length] = bubble.parent.query_columns[query][j];
                                }
                        }

                        var data = [];
                        var vm_data = {name : bubble.name};
                        
			for (var i = 0; i < bubble.values.length; i++){
                                vm_data[col_names[i]] = String(bubble.values[i]);
                        }
                        data.push(vm_data);
			$("#query_result_parallel_coord").html("");
			showParallelCoord(data);
                }
        }
        else{
		removeParallelCoord();
                $("#query_result_parallel_coord").html("Please, select a set of VM or a VM.");
        }
}

	
function updateBubbleChartLegend(data){

	var root = data;
	while ( root.parent != undefined ){
		root = root.parent;
	}

	$("#bubble_chart_legend").show();

	$("#bubble_chart_legend #legend_problem").text(root.problems);
	$("#bubble_chart_legend #legend_range").text(root.start_date+" to "+root.end_date);
	
	$("#bubble_chart_legend ul").empty();
	for (var i=0; i<root.children.length; i++){
		$("#bubble_chart_legend ul").append("<li><svg width='10' height='10' style='float:left; margin-top:5px; margin-right:5px;'><rect width='10' height='10' style='fill:"+root.children[i].color+"; stroke-width:2; stroke:rgb(0,0,0);'></rect></svg><span style='float:left;'>"+root.children[i].id+"</span></li>");
	}

}

function switchBubbleChart(){

	var d = JSON.parse($("#bubble_chart_carousel_items .active").attr('query_data'));
	updateBubbleChartLegend(d);
	$("#bubble_chart_carousel_items .active").trigger('click');
}

var id_to_color = {
'lowUsageVMs' : 'rgb(141,211,199)',
'vmsOverMemAlloc' : 'rgb(255, 255, 179)',
'vmsOverCPU' : 'rgb(190, 186, 218)',
'lowUsageVMs - vmsOverMemAlloc' : 'rgb(251, 128, 114)',
'lowUsageVMs - vmsOverCPU' : 'rgb(128, 177, 211)',
'lowUsageVMs - vmsOverCPU - vmsOverMemAlloc' : 'rgb(253, 180, 98)',
'vmsNetConstrained' : 'rgb(179, 222, 105)',
'highCPUQueueing' : 'rgb(252, 205, 229)',
'vmsWithHighPagingRate' : 'rgb(217, 217, 217)',
'highCPUQueueing - vmsNetConstrained' : 'rgb(188, 128, 189)',
'vmsNetConstrained - vmsWithHighPagingRate' : 'rgb(204, 235, 197)',
'highCPUQueueing - vmsNetConstrained - vmsWithHighPagingRate' : 'rgb(255, 237, 11)'
}

function getProperColor(node){

	var ids = node.id.split(" - ");
	ids = ids.sort();
	var parsed = ids.join(" - ");

	var color = id_to_color[parsed];
	return color;
}

function getRandomInt (min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function showBubbleChart(data){

	if ( $("#bubble_chart_carousel_items .item").size() == 0 ){
		$(".carousel-inner").empty();
		$("#bubble_chart_carousel_items").prepend("<div class='item active'></div>");
		doShowBubbleChart(data);
	}
	else{
		$("#bubble_chart_carousel_items").prepend("<div class='item'></div>");
		$("#bubble_chart_carousel").carousel(0);
		doShowBubbleChart(data);
	}	

	if ( $("#bubble_chart_carousel_items .item").size() >= 2 ){
		$(".carousel-control").show();
	}
	else{
		$(".carousel-control").hide();
	}

}

function doShowBubbleChart(data){

	var w = $("#bubble_chart_carousel").width(),
	    h = $("#bubble_chart_carousel").height(),
	    r = $("#bubble_chart_carousel").width(),
	    x = d3.scale.linear().range([0, r]),
	    y = d3.scale.linear().range([0, r]);

	var root = data;
	var node = root;

	var pack = d3.layout.pack()
	    .size([r, r])
	    .value(function(d) { return d.size; });

	var bubble_chart = d3.select("#bubble_chart_carousel_items .item")
	  .insert("svg:svg", "h2")
	    .attr("width", "100%")
	    .attr("height", "60%")
	  .append("svg:g")
	    .style("cursor", "pointer");

	var nodes = pack.nodes(root);

	for (var i=0; i<root.children.length; i++){
/*		var color = "rgb(" + getRandomInt(0, 256);
		for (var j=0; j<2; j++){
			color += "," + getRandomInt(0, 256);
		}
		color += ")";*/
		var color = getProperColor(root.children[i]);
		root.children[i].color = color;
	}

	function zoomToBubble(d, i) {

	  updateBubbleChartLegend(d);

	  if ( d == root ){
	     selectedBubble = (root.children.length == 1)? root.children[0] : null;
	  }
	  else{
	     selectedBubble = d;
	  }

	  var k = r / d.r / 2;
	  x.domain([d.x - d.r, d.x + d.r]);
	  y.domain([d.y - d.r, d.y + d.r]);

	  var t = bubble_chart.transition()
	      .duration(750);

	  t.selectAll("circle")
	    .attr("cx", function(d) { return x(d.x); })
	    .attr("cy", function(d) { return y(d.y); })
	    .attr("r", function(d) { return k * d.r; });

	  t.selectAll("text")
	    .attr("x", function(d) { return x(d.x); })
	    .attr("y", function(d) { return y(d.y); })
	    .style("opacity", function(d) { return k * d.r > 20 ? 1 : 0; });

	  $("tspan").remove();

	  bubble_chart.selectAll("text")
	     .append("svg:tspan")
    	 .style("font-size", 12)
   	  .style("cursor", "pointer")
   	  .text(function(d) { return d.name.substring(0, (k * d.r) / 3); });

	  node = d;
	  if (d3.event){
	            d3.event.stopPropagation();
	  }

	  // Update the query results chart
	  //showQueryResultChart(selectedBubble);
	  showQueryResultParallelCoord(selectedBubble);
	  // Update the metrics list
	  showTimeSeriesChart(selectedBubble);

	}

	bubble_chart.selectAll("circle")
	    .data(nodes)
	  .enter().append("svg:circle")
   	 .attr("class", function(d) { return d.children ? ( d.parent == undefined ? "root node" : "node " + ( d.class ? d.class : "" )) : "leaf node " + ( d.class ? d.class : "" ); })
 	   .attr("cx", function(d) { return d.x; })
 	   .attr("cy", function(d) { return d.y; })
 	   .attr("r", function(d) { return d.r; })
	   .style("fill", function(d) { return d.color ? d.color : ""; })
 	   .on("click", function(d) { return zoomToBubble(node == d ? root : d); });

	bubble_chart.selectAll("text")
	    .data(nodes)
	  .enter().append("svg:text")
	    .attr("class", function(d) { return d.children ? "node" : "leaf node"; })
	    .attr("x", function(d) { return d.x; })
	    .attr("y", function(d) { return d.y; })
	    .attr("dy", ".35em")
	    .attr("text-anchor", "middle")
	    .style("opacity", function(d) { return d.r > 20 ? 1 : 0; })
	  .append("svg:tspan")
	    .style("font-size", 12)
	    .style("cursor", "pointer")
	    .text(function(d) { return d.name.substring(0, d.r / 3); })

	d3.select("#bubble_chart_carousel_items .item").on("click", function() { zoomToBubble(root); });
	zoomToBubble(root);

	$("#bubble_chart_carousel_items .item").attr("query_data", JSON.stringify(root, function(key, value){
		if ( key == 'parent' ){
			return '';
		}
		else{
			return value;
		}
	}));
}
