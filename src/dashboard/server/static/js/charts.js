
var selectedBubble = null;
var metric_list = null;
var table_list = null;

function updateTimeSeries(){
	if (selectedBubble != null){
		if(selectedBubble.type == "vm"){
        		// Prepare the query 
        	        var query = "metric_time_series?vm_name=" + selectedBubble.name;
                	var selected_index = document.getElementById("metric_type_vm").selectedIndex;
			query += "&metric=" + metric_list[selected_index]
			query += "&table=" + table_list[selected_index]
			//var initial_date = new Date(selectedBubble.parent.parent.end_date);
			//initial_date.setMonth(initial_date.getMonth() - 3);
			// TODO: Create the date in the BD format
			query += "&start_date=" + selectedBubble.parent.parent.start_date;
			query += "&end_date=" + selectedBubble.parent.parent.end_date;
	        	removeTimeSeries();
			
			$("#metric_time_series").html("Loading...");
			$.get(query, function(data){
        	              	data = JSON.parse(data);
				$("#metric_time_series").html("");
				showTimeSeries(data);
        	      	});
        	}else{
			removeTimeSeries();
		}
	}else{
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
			$.get("query_metrics?query_list=" + bubble.parent.name, function (data){
							
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
        //        $("#query_result_chart").html(summary);
        }
        else{
		removeParallelCoord();
                summary += "Please, select a set of VMs or a VM.";
        //        $("#query_result_chart").html(summary);
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

function showBubbleChart(data){
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
	
	$("#bubble_chart_carousel_items .item").removeClass("active");
	$("#bubble_chart_carousel_items").prepend("<div class='active item'></div>");

	if ( $("#bubble_chart_carousel_items .item").size() >= 2 ){
		$(".carousel-control").show();
	}
	else{
		$(".carousel-control").hide();
	}

	var bubble_chart = d3.select("#bubble_chart_carousel_items .active")
	  .insert("svg:svg", "h2")
	    .attr("width", "100%")
	    .attr("height", "100%")
	  .append("svg:g")
	    .attr("transform", "translate(" + (w - r) / 2 + "," + (h - r) / 2 + ")")
	    .style("cursor", "pointer");

	$("svg").append("<g class='legend'></g>");

	var legend = $("svg .legend");

//	legend.style("cursor", "pointer ")
//	  .append("<rect x='0' y='0' width='100' height='100' style='fill:blue;'></rect>");

	var nodes = pack.nodes(root);

	bubble_chart.selectAll("circle")
	    .data(nodes)
	  .enter().append("svg:circle")
   	 .attr("class", function(d) { return d.children ? "node " + ( d.class ? d.class : "" ) : "leaf node " + ( d.class ? d.class : "" ); })
 	   .attr("cx", function(d) { return d.x; })
 	   .attr("cy", function(d) { return d.y; })
 	   .attr("r", function(d) { return d.r; })
 	   .on("click", function(d) { return zoom(node == d ? root : d); });

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

	d3.select("#bubble_chart_carousel_items .active").on("click", function() { zoom(root); });

	function zoom(d, i) {

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
	zoom(root);
}
