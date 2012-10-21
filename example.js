var connect = require('connect'),
	sharejs = require('share').server,
	span = require('./lib/index.js');


var sessionStore = new connect.session.MemoryStore();


var server = connect.createServer();
server.use(connect['static'](__dirname + "/static"))
      .use(connect.cookieParser("HUwV6GnE2u7wk5hAj64Ub3ifyq342bsWSCenk9PQs7sS6qBscAVG9FeGiDfHwJ9LpdMMwwBa"))
      .use(connect.session({secret: "HUwV6GnE2u7wk5hAj64Ub3ifyq342bsWSCenk9PQs7sS6qBscAVG9FeGiDfHwJ9LpdMMwwBa", store: sessionStore}));



var authorizer = span.createAuthorizer(server)
	.use(span.snapshot)
	.use(span.connectSession(sessionStore))
	.use(function(agent, action, next) {
		console.log("SESSION:", agent.session);
		console.log("SNAP:", action.snapshot);
		action.accept();
	});


sharejs.attach(server, { browserChannel: {cors: '*'}, db: {type: 'none'}, auth: authorizer });

var port = 5000;
server.listen(port, function() { console.log("Listening on " + port); });