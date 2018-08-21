const express = require('express')
// const bodyParser = require('body-parser')
const http = require('http');

const app = express()

//Allow all requests from all domains & localhost
app.all('/*', function (req, res, next) {
	res.header("Access-Control-Allow-Origin", "*")
	res.header("Access-Control-Allow-Headers", "X-Requested-With, Content-Type, Accept")
	res.header("Access-Control-Allow-Methods", "GET")
	next()
})

// app.use(bodyParser.json())
// app.use(bodyParser.urlencoded({
// 	extended: false
// }))

app.get('/data', (req, res) => {
	if (req.query.type == "mean") {
		
		const time = req.query.time ? req.query.time : '1h'
		
		http.request({
			host: 'localhost',
			port: '8086',
			path: '/query?&db=test&q=select%20mean%28%2A%29%20from%20atmos%20where%20time%20%3E%20now%28%29%20-%20' + time + '%20group%20by%20host'
		}, (r) => {
			var str = ''
			r.on('data', (c) => {
				str += c;
			});

			r.on('end', () => {
				str = JSON.parse(str)
				str = str.results[0].series
				var d = []

				for (let i in str) {
					d[i] = {
						host: str[i].tags.host,
						time: str[i].values[0][0],
						cpu_usage: +str[i].values[0][2],
						mem_usage: +str[i].values[0][4],
						cpu_temp: +str[i].values[0][1],
						humi: +str[i].values[0][3],
						temp: +str[i].values[0][5]
					}
				}

				res.send(d)
			});
		}).end();
	} else if ( req.query.type == "val") {
		console.log(req.query.count)
		const count = req.query.count ? req.query.count : 1
		
		http.request({
			host: 'localhost',
			port: '8086',
			path: '/query?&db=test&q=select%20%2A%20from%20atmos%20group%20by%20host%20limit%20' + count
		}, (r) => {
			var str = ''
			r.on('data', (c) => {
				str += c;
			});

			r.on('end', () => {
				str = JSON.parse(str)
				str = str.results[0].series
				var d = []

				for (let i in str) {
					d[i] = []
					for ( let j in str[i].values ) {
						d[i][j] = {
							host: str[i].tags.host,
							time: str[i].values[0][0],
							cpu_usage: +str[i].values[0][2],
							mem_usage: +str[i].values[0][4],
							cpu_temp: +str[i].values[0][1],
							humi: +str[i].values[0][3],
							temp: +str[i].values[0][5]
						}
					}
				}

				res.send(d)
			});
		}).end();
		
	}

})

app.listen(3000, (error) => {
	if (error) console.log(error)
	console.log('Example app listening on port 3000!')
})