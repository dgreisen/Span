parseCookie = require('connect').utils.parseCookie

module.exports = (store, once=false) ->
	return (agent, action, next) ->
		if once and agent.session then return next()
		cookie = parseCookie(agent.headers.cookie)
		store.get cookie['connect.sid'], (err, session) ->
			agent.session = session
			return next()