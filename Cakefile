# build script adapted from ShareJS

{exec} = require 'child_process'

task 'test', 'Run all tests', ->
	# run directly to get all the delicious output
	console.log 'Running tests...'
	exec 'nodeunit ./tests/span.coffee', (err, stdout, stderr) ->
		throw err if err

task 'build', 'Build the .js files', (options) ->
	console.log('Compiling Coffee from src to lib')
	exec "coffee --compile --bare --output lib/ src/", (err, stdout, stderr) ->
		throw err if err
		console.log stdout + stderr

task 'watch', 'Watch src directory and build the .js files', (options) ->
	console.log('Watching Coffee in src and compiling to lib')
	cp = exec "coffee --watch --bare --output lib/ src/"
	cp.stdout.on "data", (data) -> console.log(data)
	cp.stderr.on "data", (data) -> console.log(data)