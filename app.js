const d3 = require('d3')
global.fetch = require('node-fetch')

d3.json("http://pinas:8086/query?db=test&q=select%20%2A%20from%20usage").then(d => {
	let re = d.results[0].series[0]

	console.log(re.columns[0])
	console.log(re.values[1])
	// re.values.forEach(e => {
	// 	console.log(e)
	// });
}).catch(e => {
	console.log(e)
})