module.exports = (agent, action, next) ->
	# if creating -> no snapshot -> move to next middleware
	if action.type == "create" or action.type == "connect" then return next()
	agent.app.model.getSnapshot action.docName, (err, snapshot) ->
		action.snapshot = snapshot;
		return next()