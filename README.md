Span.js
=======

Span.js is middleware for [ShareJS](https://github.com/josephg/ShareJS/)
licensed under the 
[Apache License, v2.0](http://www.apache.org/licenses/LICENSE-2.0). It steals
shamelessly from [Connect](https://github.com/senchalabs/connect).

Example
-------

	connect = require('connect')
	sharejs = require('share').server
	span = require('./lib/index.js')


	server = connect.createServer()

	usernum = 0

	# create an authorizer object
	authorizer = span.createAuthorizer(server)
		
		# set agent.name to the next usernum when there is a new connection
		.CONNECT (agent, action, next) ->
			agent.name = usernum++
			next()
		
		# set action.snapshot to the current snapshot
		.use(span.snapshot)
		
		# log the snapshot every time an action occurs
		.use (agent, action, next) ->
			console.log "SNAPSHOT:", action.
			next()
		
		# even numbered users can access documents starting with 'even-'
		.use /$even-/, (agent, action, next) -> 
			if not (agent.name % 2) then action.accept() else action.reject()

		# allow all other actions
		.use (agent, action, next) ->
			action.accept()

	sharejs.attach(server, { browserChannel: {cors: '*'}, db: {type: 'none'}, auth: authorizer })

	port = 5000
	server.listen(port, -> console.log("Listening on " + port))

Usage
-----
First create an authorizer object by calling 
`authorizer = span.createAuthorizer(server)`, where `server` is the connect
server instance. The authorizer will set `agent.app` to point to your server
so you always have access to it, and therefore the ShareJS model at 
`agent.app.model`.

Next, you attach middleware to the authorizer. A middleware function is of
the form:

	(agent, action, next) ->
		# code to:
		#    * add attributes to agent or action
		#    * call action.accept() or action.reject()

		# call next if subsequent middleware should be run
		next()

Middleware is attached to authorizer by calling `authorizer.use(middleware)`.
If you provide a regular expression with your middleware, it will only be
run if the document name matches the regular expression. Thus 
`authorizer.use(regex, middleware)` will only run when `action.docName`
matches the regex. 

You can also further limit when a middleware is run by attaching it using an
action TYPE verb: CONNECT, CREATE, READ, UPDATE, DELETE. Thus
`authorizer.CREATE(middleware)` will only be run for actions of type create.
You can combine the type verbs with regexes:
`authorizer.CREATE(regex, middleware)` will only run for actions whose 
document name matches the regex and whose type is create.

Included Middleware
-------------------

* `span.snapshot': sets `action.snapshot` to the document's current snapshot
* `span.connectSession(sessionStore, once`: sets `agent.session` to the
	current connect session. You must pass it the sessionStore you passed to
	the connect session middleware. If you only need to get the session once,
	and it won't be changing after CONNECT, then set `once=true` to save on
	calls to the session db.

Contributing
------------

If you write a middleware that would be useful for other people, please send
a pull request, I'll be happy to include it.

You can run all tests by calling `cake test`.