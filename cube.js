// create context and horizon
const datasize = 960;
var context = cubism.context().size(datasize)
var horizon = context.horizon().extent([0, 2])
var metrics = []

d3.json('http://localhost:3000/data?type=val&count=1', (d) => {
  drawGraph(handled(d))
  make()
})

function handled(d) {
  return d[0]
}

function drawGraph(d) {
  metrics.push(d.host)
}

function getData(callback) {
  d3.json('http://localhost:3000/data?type=val&count=' + datasize, (d) => {
    console.log(d)
    d = handled(d)

    var values = []

    for (let i in d) {
      // values[i] = d[i].cpu_temp
      values[i] = Math.random()
    }

    values.push(d.cpu_temp)

    callback(null, values);
  })

}

// define metric accessor
function addData(name) {
  return context.metric(function (start, stop, step, callback) {
    getData(callback)
  }, name);
}

function make() {
  horizon.metric(addData)

  d3.select("#graph").selectAll(".horizon")
    .data(metrics)
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