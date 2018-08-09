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
	// console.log(req)

	http.request({
		host: 'localhost',
		port: '8086',
		path: '/query?&db=test&q=select%20mean%28%2A%29%20from%20atmos%20where%20time%20%3E%20now%28%29%20-%201m%20group%20by%20host'
	}, (r) => {
		var str = ''
		r.on('data', (c) => {
			str += c;
		});

		r.on('end', () => {
			res.send(str)
		});
	}).end();

})

app.listen(3000, (error) => {
	if (error) console.log(error)
	console.log('Example app listening on port 3000!')
})