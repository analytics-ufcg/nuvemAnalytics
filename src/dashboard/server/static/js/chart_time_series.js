function showTimeSeries(data){
        var w = $("#metric_time_series").width(),
            h = $("#metric_time_series").height();
	var margin = {top: 20, right: 40, bottom: 10, left: 60};
	var width_axis = w - (margin.left + margin.right),
	    height_axis = h - (margin.top + margin.bottom);
		
	var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;

	var x = d3.time.scale()
		.range([0, width_axis]);

	var y = d3.scale.linear()
		.range([height_axis, 0]);

	var color = d3.scale.category10();

	var xAxis = d3.svg.axis()
		.scale(x)
		.orient("bottom");

	var yAxis = d3.svg.axis()
		.scale(y)
		.orient("left");

	var line = d3.svg.line()
		.defined(function(d) { return !isNaN(d.metric); })
		.interpolate("basis")
		.x(function(d) { return x(d.date); })
		.y(function(d) { return y(d.metric);});

	var svg = d3.select("#metric_time_series").append("svg")
		.attr("width", "100%")
		.attr("height", "100%")
	  .append("g")
		.attr("transform", "translate(" + margin.left + ", 5)");

	function showChart(data) {
	
		color.domain(d3.keys(data[0]).filter(function(key) { return key !== "date"; }));

		data.forEach(function(d) {
			d.date = parseDate(d.date);
		});

		var vms = color.domain().map(function(name) {
		return {
		  name: name,
		  values: data.map(function(d) {
			return {date: d.date, metric: +d[name]};
		  })
		};
		});

		x.domain(d3.extent(data, function(d) { return d.date; }));
		
		y_min = d3.min(vms, function(c) { return d3.min(c.values, function(v) { return v.metric; }); });
		y_max = d3.max(vms, function(c) { return d3.max(c.values, function(v) { return v.metric; }); });

		if (y_min == y_max){
			if (y_min == 0){
				y.domain([-2, 2]);
			}else{
				y.domain([y_min - y_min, y_min + y_min]);
			}
		}else {
			y.domain([y_min, y_max]);
		}

		svg.append("g")
		  .attr("class", "x axis")
		  .attr("transform", "translate(0," + height_axis + ")")
		  .call(xAxis);

		svg.append("g")
		  .attr("class", "y axis")
		  .call(yAxis)
		.append("text")
		  .attr("transform", "rotate(-90)")
		  .attr("y", 6)
		  .attr("dy", ".71em")
		  .style("text-anchor", "end");
//		  .text("Metric");

		var vm_metric = svg.selectAll(".vm_metric")
		  .data(vms)
		.enter().append("g")
		  .attr("class", "vm_metric");

		vm_metric.append("path")
		  .attr("class", "line")
		  .attr("d", function(d) { return line(d.values); })
		  .style("stroke", function(d) { return color(d.name); });

		vm_metric.append("text")
		  .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
		  .attr("transform", function(d) { return "translate(" + x(d.value.date) + "," + y(d.value.metric) + ")"; })
		  .attr("x", 3)
		  .attr("dy", ".35em")
		  .text(function(d) { return d.name; });
	}

	showChart(data);
}

function removeTimeSeries(){
	d3.select("#metric_time_series").selectAll("svg").remove();
}
