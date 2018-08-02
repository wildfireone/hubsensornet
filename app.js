		var margin = {
				top: 30,
				right: 10,
				bottom: 10,
				left: 10
			},
			width = 960 - margin.left - margin.right,
			height = 500 - margin.top - margin.bottom;

		var x = d3.scale.ordinal().rangePoints([0, width], 1),
			y = {};

		var line = d3.svg.line(),
			axis = d3.svg.axis().orient("left"),
			background,
			foreground;

		var svg = d3.select("body").append("svg")
			.attr("width", width + margin.left + margin.right)
			.attr("height", height + margin.top + margin.bottom)
			.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

		d3.json(
			"http://pihost:8086/query?&db=test&q=select%20mean%28%2A%29%20from%20usage%20where%20time%20%3E%20now%28%29%20-%201m%20group%20by%20host",
			function (error, data) {
				data = data.results[0].series
				console.log(data)

				if (error) console.log(error)


				// Extract the list of dimensions and create a scale for each.
				x.domain(dimensions = d3.keys(data[0].columns).filter(function (d) {
					console.log(d)
					return d != 0 && (y[d] = d3.scale.linear()
						.domain(d3.extent(data, function (p) {
							console.log(p[d])
							return +p[d]
						}))
						.range([height, 0]));
				}));

				x.domain()

				// Add grey background lines for context.
				background = svg.append("g")
					.attr("class", "background")
					.selectAll("path")
					.data(data.values)
					.enter().append("path")
					.attr("d", path);

				// Add blue foreground lines for focus.
				foreground = svg.append("g")
					.attr("class", "foreground")
					.selectAll("path")
					.data(data.values)
					.enter().append("path")
					.attr("d", path);

				// Add a group element for each dimension.
				var g = svg.selectAll(".dimension")
					.data(dimensions)
					.enter().append("g")
					.attr("class", "dimension")
					.attr("transform", function (d) {
						return "translate(" + x(d) + ")";
					});

				// Add an axis and title.
				g.append("g")
					.attr("class", "axis")
					.each(function (d) {
						d3.select(this).call(axis.scale(y[d]));
					})
					.append("text")
					.style("text-anchor", "middle")
					.attr("y", -9)
					.text(function (d) {
						return d;
					});

				// Add and store a brush for each axis.
				g.append("g")
					.attr("class", "brush")
					.each(function (d) {
						d3.select(this).call(y[d].brush = d3.svg.brush().y(y[d]).on("brush", brush));
					})
					.selectAll("rect")
					.attr("x", -8)
					.attr("width", 16);
			});

		// Returns the path for a given data point.
		function path(d) {
			return line(dimensions.map(function (p) {
				return [x(p), y[p](d[p])];
			}));
		}

		// Handles a brush event, toggling the display of foreground lines.
		function brush() {
			var actives = dimensions.filter(function (p) {
					return !y[p].brush.empty();
				}),
				extents = actives.map(function (p) {
					return y[p].brush.extent();
				});
			foreground.style("display", function (d) {
				return actives.every(function (p, i) {
					return extents[i][0] <= d[p] && d[p] <= extents[i][1];
				}) ? null : "none";
			});
		}