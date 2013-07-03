var selectedBubble = null;
var metric_list = null;
var table_list = null;
var ts_jquery = null;
var zoomToBubble = null;

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

			var start_date = new Date(Date.parse(selectedBubble.parent.parent.end_date) - 7776000000); //3 months in millisseconds
			start_date = start_date.getFullYear()+"-"+pad(start_date.getMonth()+1)+"-"+pad(start_date.getDay())+" "+pad(start_date.getHours())+":"+pad(start_date.getMinutes())+":"+pad(start_date.getSeconds());
			console.log("start_date is "+start_date);
			query += "&start_date=" + start_date;
			query += "&end_date=" + selectedBubble.parent.parent.end_date;
	        	removeTimeSeries();
			
			$("#metric_time_series").html("<img src='static/img/ajax-loader.gif'></img>");
			ts_jquery = $.get(query, function(data){
        	              	data = JSON.parse(data);
				$("#metric_time_series").html("");
				showTimeSeries(data);
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

	var div_text = "";
	
	if(bubble != null){	
		if(bubble.type == "vm"){
			// Call the server to get the metrics and tables
			$.get("query_metrics?query_list=" + bubble.parent.id, function (data){
							
				data = JSON.parse(data);
				metric_list = data.metrics;
				table_list = data.tables;

				$("#metric_type_vm").show();

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
			div_text += "Please select a VM";
			updateTimeSeries();
		}
	}else{
		div_text += "Please select a VM";
 		updateTimeSeries();
	}
	$("#metric_time_series").html(div_text);
}	

function showQueryResultParallelCoord(bubble){
       var summary = "<h4>Queries Result Summary</h4>";
        if ( bubble != null ){
		$("#query_result_chart").html(summary);
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

			showParallelCoord(data);
                }
            //    $("#query_result_chart").html(summary);
        }
        else{
		removeParallelCoord();
                summary += "Please, select a set of VMs or a VM.";
                $("#query_result_chart").html(summary);
        }
}

	
function showQueryResultChart(bubble){

	function compareNumbers(a, b) {
 		 return a - b;
	}
	var summary = "<h4>Queries Result Summary</h4>";
	if ( bubble != null ){
		if (bubble.type == "vm_set"){

                        // Select the queries and the columns
                        var queries = bubble.query_names;
                        var col_names = new Array();
                        for (var i = 0; i < queries.length; i++){
                                query = queries[i];
                                for (var j = 0; j < bubble.query_columns[query].length; j++){
                                        col_names[col_names.length] = bubble.query_columns[query][j];
                                }
                        }
			
			// Matrix of (col_values x vms), we switched the axis to calculate the summary easily
			col_values = new Array();
			summary_values = new Array();

			for (var i = 0; i < col_names.length; i++){
				col_values[col_values.length] = new Array();
				for (var j = 0; j < bubble.children.length; j++){
					col_values[i][j] = bubble.children[j].values[i];
				}
				
				// Calculate the summary metrics
				col_values[i].sort(compareNumbers);
				summary_values[i] = new Array();
				summary_values[i][0] = d3.quantile(col_values[i], 0).toFixed(2);
				summary_values[i][1] = d3.quantile(col_values[i], 0.25).toFixed(2);
				summary_values[i][2] = d3.quantile(col_values[i], 0.5).toFixed(2);
				summary_values[i][3] = d3.quantile(col_values[i], 0.75).toFixed(2);
				summary_values[i][4] = d3.quantile(col_values[i], 1).toFixed(2);
			}

			// Print the table
                        summary += "<table border=\"1\">";
			summary += "<thead><tr><th></th>";

			for (var i = 0; i < queries.length; i++){
				summary += "<th scope=\"col\" colspan=\"" + bubble.query_columns[queries[i]].length;
				summary += "\">" + queries[i] + "</th>";
			}
			summary += "</tr><th></th>";

			for (var i = 0; i < col_names.length; i++){
				summary += "<th>" + col_names[i] + "</th>";
			}
			summary += "</tr></thead><tbody>";

                        summary_columns = new Array("Min", "1st Quartile", "Median", "3rd Quartile", "Max");
			for (var i = 0; i < summary_values[0].length; i++){
				summary += "<tr>";
				summary += "<td><strong>" + summary_columns[i] + "</strong></td>";
				for (var j = 0; j < summary_values.length; j++){
					summary += "<td>" + summary_values[j][i] + "</td>"
				}
				summary += "</tr>";
			}

			summary += "</tbody></table>"
		}
		if (bubble.type == "vm"){

			// Select the queries and the columns
			var queries = bubble.parent.query_names;
			var col_names = new Array();
			for (var i = 0; i < queries.length; i++){
				query = queries[i];
				for (var j = 0; j < bubble.parent.query_columns[query].length; j++){
					col_names[col_names.length] = bubble.parent.query_columns[query][j];
				}
			}

                        // Print the table
                        summary += "<table border=\"1\">";
                        summary += "<thead><tr><th></th>";

                        for (var i = 0; i < queries.length; i++){
                                summary += "<th scope=\"col\" colspan=\"" + bubble.parent.query_columns[queries[i]].length;
                                summary += "\">" + queries[i] + "</th>";
                        }
                        summary += "</tr><th></th>";

                        for (var i = 0; i < col_names.length; i++){
                                summary += "<th>" + col_names[i] + "</th>";
                        }
                        summary += "</tr></thead><tbody>";
			summary += "<tr><td><strong>" + bubble.name + "</strong></td>";
			
                        for (var i = 0; i < bubble.values.length; i++){
                                summary += "<td>" + bubble.values[i] + "</td>";
                        }
                        summary += "</tr></tbody></table>";

			vm_values = ""
			for (var i = 0; i < bubble.values.length; i++){
				vm_values += bubble.values[i] + "\t";
			}
		}
                $("#query_result_chart").html(summary);

	}
	else{
		summary += "Please, select a set of VMs or a VM.";
		$("#query_result_chart").html(summary);
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
