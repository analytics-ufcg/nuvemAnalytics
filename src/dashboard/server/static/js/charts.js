var selectedBubble = null;

function showQueryResultChart(selectedBubble){
	
//	console.log("calling this and selectedBubble is: ");
//	console.log(selectedBubble);
	if ( selectedBubble != null ){
		var summary = "";
		if (selectedBubble.type == "vm_set"){
			summary += selectedBubble.name
			$("#query_result_chart").text(summary);
		}
		if (selectedBubble.type == "vm"){
                        summary += selectedBubble.name
                        $("#query_result_chart").text(summary);

		}
	}
	else{
		$("#query_result_chart").text("null");
	}
}

function showBubbleChart(data){

	var w = $("#bubble_chart").width(),
	    h = $("#bubble_chart").height(),
	    r = $("#bubble_chart").width(),
	    x = d3.scale.linear().range([0, r]),
	    y = d3.scale.linear().range([0, r]);

	var root = data;
	var node = root;

	var pack = d3.layout.pack()
	    .size([r, r])
	    .value(function(d) { return d.size; });

	var vis = d3.select("#bubble_chart")
	  .insert("svg:svg", "h2")
	    .attr("width", "100%")
	    .attr("height", "100%")
	  .append("svg:g")
	    .attr("transform", "translate(" + (w - r) / 2 + "," + (h - r) / 2 + ")")
	    .style("cursor", "pointer");

	var nodes = pack.nodes(root);

	vis.selectAll("circle")
	    .data(nodes)
	  .enter().append("svg:circle")
   	 .attr("class", function(d) { return d.children ? "node " + ( d.class ? d.class : "" ) : "leaf node " + ( d.class ? d.class : "" ); })
 	   .attr("cx", function(d) { return d.x; })
 	   .attr("cy", function(d) { return d.y; })
 	   .attr("r", function(d) { return d.r; })
 	   .on("click", function(d) { return zoom(node == d ? root : d); });

	vis.selectAll("text")
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

	d3.select("#bubble_chart").on("click", function() { zoom(root); });

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

	  var t = vis.transition()
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

	  vis.selectAll("text")
	     .append("svg:tspan")
	     .style("font-size", 12)
	     .style("cursor", "pointer")
	     .text(function(d) { return d.name.substring(0, (k * d.r) / 3); });

	  node = d;
	  if (d3.event){
             d3.event.stopPropagation();
	  }

	  //update the query results chart
	  showQueryResultChart(selectedBubble);
	}

	zoom(root);
}