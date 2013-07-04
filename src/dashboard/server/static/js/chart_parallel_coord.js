var line_pc = d3.svg.line(),
    axis_pc = d3.svg.axis().orient("left"),
    background_pc,
    foreground_pc;
var x_pc = d3.scale.ordinal(),
    y_pc = {},
    dragging_pc = {};

function showParallelCoord(data) {

	var div_width = $("#query_result_parallel_coord").width(),
		div_height = $("#query_result_parallel_coord").height();
	
	var m = {left:70, right:70, top:20, bottom:20},
		w = div_width - m.left - m.right,
		h = div_height - m.top - m.bottom;

	var svg = d3.select("#query_result_parallel_coord").append("svg:svg")
		.attr("width", "100%")
		.attr("height", "100%")
	  .append("svg:g")
		.attr("transform", "translate(" + m.left + "," + m.top + ")");

  // Extract the list of dimensions and create a scale for each.
  x_pc.domain(dimensions = d3.keys(data[0]).filter(function(d) {
	  if (d != "name"){
		  y_extent = d3.extent(data, function(p) { return +p[d]; });

		  if (y_extent[0] == y_extent[1]){
			  eq_value = y_extent[0];
			if (eq_value == 0){
				y_extent = [eq_value - 1, eq_value + 1];
			}else{
				y_extent = [eq_value - eq_value/2, eq_value + eq_value/2]; 
			}
		  }

		  y_pc[d] = d3.scale.linear()
				.domain(y_extent)
				.range([h, 0]);
			
			return true;
	  }else{
			return false;
	  }
  })).rangePoints([0, w]);

  // Add grey background lines for context.
  background_pc = svg.append("svg:g")
      .attr("class", "background")
    .selectAll("path")
      .data(data)
    .enter().append("svg:path")
      .attr("d", path);

  // Add blue foreground lines for focus.
  foreground_pc = svg.append("svg:g")
      .attr("class", "foreground")
    .selectAll("path")
      .data(data)
    .enter().append("svg:path")
      .attr("d", path);

  // Add a group element for each dimension.
  var g = svg.selectAll(".dimension")
      .data(dimensions)
    .enter().append("svg:g")
      .attr("class", "dimension")
      .attr("transform", function(d) { return "translate(" + x_pc(d) + ")"; })
      .call(d3.behavior.drag()
        .on("dragstart", function(d) {
          dragging_pc[d] = this.__origin__ = x_pc(d);
          background_pc.attr("visibility", "hidden");
        })
        .on("drag", function(d) {
          dragging_pc[d] = Math.min(w + 40, Math.max(-40, this.__origin__ += d3.event.dx));
          foreground_pc.attr("d", path);
          dimensions.sort(function(a, b) { return position(a) - position(b); });
          x_pc.domain(dimensions);
          g.attr("transform", function(d) { return "translate(" + position(d) + ")"; })
        })
        .on("dragend", function(d) {
          delete this.__origin__;
          delete dragging_pc[d];
          transition(d3.select(this)).attr("transform", "translate(" + x_pc(d) + ")");
          transition(foreground_pc)
              .attr("d", path);
          background_pc
              .attr("d", path)
              .transition()
              .delay(500)
              .duration(0)
              .attr("visibility", null);
        }));

  // Add an axis and title.
  g.append("svg:g")
      .attr("class", "axis")
      .each(function(d) { d3.select(this).call(axis_pc.scale(y_pc[d])); })
    .append("svg:text")
      .attr("text-anchor", "middle")
      .attr("y", -9)
      .text(String);

  // Add and store a brush for each axis.
  g.append("svg:g")
      .attr("class", "brush")
      .each(function(d) { d3.select(this).call(y_pc[d].brush = d3.svg.brush().y(y_pc[d]).on("brush", brush)); })
    .selectAll("rect")
      .attr("x", -8)
      .attr("width", 16);
}

function position(d) {
  var v = dragging_pc[d];
  return v == null ? x_pc(d) : v;
}

function transition(g) {
  return g.transition().duration(500);
}

// Returns the path for a given data point.
function path(d) {
  return line_pc(dimensions.map(function(p) { return [position(p), y_pc[p](d[p])]; }));
}

// Handles a brush event, toggling the display of foreground lines.
function brush() {
  var actives = dimensions.filter(function(p) { return !y_pc[p].brush.empty(); }),
      extents = actives.map(function(p) { return y_pc[p].brush.extent(); });
  foreground_pc.style("display", function(d) {
    return actives.every(function(p, i) {
      return extents[i][0] <= d[p] && d[p] <= extents[i][1];
    }) ? null : "none";
  });
}

function removeParallelCoord(){
        d3.select("#query_result_chart").selectAll("svg").remove();
}

