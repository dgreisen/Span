utils = require("connect").utils
proto = require("./proto")
snapshot = require("./middleware/snapshot")
connectSession = require("./middleware/connectSession")
exports.createAuthorizer = (app, middleware...) -> 
	auth = (agent, action) -> 
		agent.app = app
		auth.handle(agent, action)
	utils.merge(auth, proto)
	auth.stack = []
	auth.use(m) for m in middleware

	return auth

exports.snapshot = snapshot
exports.connectSession = connectSession