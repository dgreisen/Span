module.exports = (store) ->
	return (agent, action, next) ->
	    var cookie = parseCookie(agent.headers.cookie)
        store.get cookie['connect.sid'], (err, session) ->
        	agent.session = session
        	next()