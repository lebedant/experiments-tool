// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/


// data is JSON
// data = [{ name: "A", value: 1 }, {...}, {..}]
function drawBarPlot(caption, data, id) {
  var formatCount = d3.format(",.2f");

  var charts = $("#charts");
  charts.append($("<div id="+id+"></div>"))
  // set the dimensions and margins of the graph
  var margin = {top: 30, right: 20, bottom: 20, left: 20};
  var width = (charts.width() - margin.left - margin.right),
      height = 250 - margin.top - margin.bottom;
      // width = 640 - margin.left - margin.right,
      // height = 332 - margin.top - margin.bottom;

  // set the ranges
  var x = d3.scaleBand()
            .range([0, width])
            .padding(0.1);
  var y = d3.scaleLinear()
            .range([height, 0]);

  // append the svg object to the body of the page
  var svg = d3.select('#'+id).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform",
            "translate(" + margin.left + "," + margin.top + ")");
  // append plot caption
  svg.append("text")
        .attr("x", (width / 2))
        .attr("y", 0 - (margin.top / 2))
        .attr("text-anchor", "middle")
        .style("font-size", "16px")
        .style("text-decoration", "underline")
        .text(caption);

  // Scale the range of the data in the domains
  x.domain(data.map(function(d) { return d.name; }));
  y.domain([0, d3.max(data, function(d) { return d.value; })]);


  var barWidth = width / data.length;

  var bar = svg.selectAll("g")
      .data(data)
    .enter().append("g")
      .attr("transform", function(d, i) { return "translate(" + i * barWidth + ",0)"; });

  // append the rectangles for the bar chart
  bar.append("rect")
      .attr("class", "bar")
      .attr("y", function(d) { return y(d.value); })
      .attr("height", function(d) { return height - y(d.value); })
      .attr("width", barWidth - 1);

  // append text for rectangles with bar value
  bar.append("text")
      .attr("class", "bar-text")
      .attr("x", (barWidth / 2) - 15)
      .attr("y", function(d) { return y(d.value) + 8; })
      .attr("dy", ".75em")
      .text(function(d) { return formatCount(d.value); });

  // add the x Axis
  svg.append("g")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x));

  // add the y Axis
  svg.append("g")
      .call(d3.axisLeft(y));
}

