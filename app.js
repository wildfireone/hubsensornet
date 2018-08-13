const val = document.getElementById('time-increments')

val.addEventListener('change',function() {
    build(val.value)
},false)

function build(time) {
    console.log(time)
    const color = (d) => { return d3.scale
        .linear()
        .domain([9, 50])
        .range(["steelblue", "brown"])
        .interpolate(d3.interpolateLab)(d['time']) }

    const parcoords = d3
        .parcoords()('#para')
        .color(color)
        .alpha(0.4)

    d3.json('http://pihost:3000/data?time=' + time, (data) => {
    parcoords
        .data(data)
        .hideAxis(["time", "host"])
        .composite("darker")
        .render()
        .shadows()
        .reorderable()
        .brushMode("1D-axes")
    })
}