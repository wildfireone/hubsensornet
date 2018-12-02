// create context and horizon
const datasize = 960;
var context = cubism.context().size(datasize)
var horizon = context.horizon().extent([0, 2])
var metrics = []

d3.json('http://pihost:3000/data?type=val&count=1', (d) => {
  drawGraph(handled(d))
  make()
})

function handled(d) {
  return d[0]
}

function drawGraph(d) {
    metrics.push(d[0].host)

}

// define metric accessor
function addData(name) {
  return context.metric(function (start, stop, step, callback) {
    d3.json('http://pihost:3000/data?type=val&count=' + datasize, (d) => {
      var values = []
      d = handled(d)
  
      for ( let i in d ) {
        if ( "" + name === "cpu_usage" )
          values.push(d[i][""+name])
        else
        values.push((d[i][""+name]/100))
      }
  
      callback(null, values);
    })
  }, name);
}

function make() {
  horizon.height("60").metric(addData)

  d3.select("#graph").selectAll(".horizon")
  .data(["cpu_usage", "mem_usage", "cpu_temp", "temp", "humi"].map(addData))
    .enter()
    .append("div")
    .attr("class", "horizon")
    .call(horizon);
  
  // set rule
  d3.select("#body").append("div")
    .attr("class", "rule")
    .call(context.rule());

  // set focus
  context.on("focus", function (i) {
    d3.selectAll(".value")
      .style("right", i == null ? null : context.size() - i + "px");
  });
  // set axis
  var axis = context.axis()
  d3.select("#graph").append("div").attr("class", "axis").append("g").call(axis);
}