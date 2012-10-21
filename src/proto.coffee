auth = module.exports = {}

###
`regexp` is a regexp for matching a document name
(a regular expresson, or a string converted to a regexp that
matches only that string). `type` is a string
corresponding to the action types: `connect`, `create`,
`update`, `read` or `delete`.
###

auth.use = (regexp, fn, type=null) ->
	if typeof regexp == "string"
		regexp = new RegExp("^"+regexp+"$")
	else if regexp instanceof Function
		fn = regexp
		regexp = null

	# add the middleware
	@stack.push({ regexp: regexp, type: type, handle: fn })

	return this

auth.CREATE = (regexp, fn) ->
	return @use(regexp, fn, "create")
auth.CONNECT = (regexp, fn) ->
	return @use(regexp, fn, "connect")
auth.UPDATE = (regexp, fn) ->
	return @use(regexp, fn, "update")
auth.READ = (regexp, fn) ->
	return @use(regexp, fn, "read")
auth.DELETE = (regexp, fn) ->
	return @use(regexp, fn, "delete")

auth.handle = (agent, action, out) ->
	stack = this.stack
	index = 0
	next = (err) ->
		# next callback
		layer = stack[index++]

		# all done
		if action.responded
			return
		else if not layer
			# delegate to parent
			if out then return out(err)

			# otherwise, default to rejecting the operation
			return action.reject()
			
		try
			docName = action.docName

			# skip this layer if the regexp doesn't match the docName

			if layer.regexp and (not docName? or not layer.regexp.test(docName))
				return next(err)
			# skip this layer if the action doesn't match the type
			if layer.type and layer.type != action.type then return next(err)
			arity = layer.handle.length
			if err
				if arity == 4
					return layer.handle(err, agent, action, next)
				else
					return next(err)
			else if arity < 4
				return layer.handle(agent, action, next)
			else
				return next()
		catch e
			console.log('found error', e)
			next(e)

	next()

