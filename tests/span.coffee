span = require "../lib/index"



module.exports = 
  setUp: (callback) ->
    @agent = {}
    @action =
      name: "connect",
      type: "connect",
      responded: false
      accept: () -> 
        if @responded 
          throw "responded more than once"
        else 
          @responded = "accepted"
          @finished()
      reject: (msg) ->
        if @responded 
          throw "responded more than once"
        else
          @responded = "forbidden"
          @finished()
      finished: ->
      testRejected: (test) ->
        test.strictEqual @responded, "forbidden"
      testAccepted: (test) ->
        test.strictEqual @responded, "accepted"
    @authorizer = span.createAuthorizer("SERVER")
    callback()

  "auth should attach the server to the agent": (test) ->
    @action.finished = =>
      test.equal @agent.app, "SERVER"
      test.done()

    @authorizer @agent, @action

  "auth should always reject if no middleware": (test) ->
    @action.finished = =>
      @action.testRejected(test)
      test.done()

    @authorizer @agent, @action

  "use should be chainable and add middleware to the stack in the appropriate order": (test) ->
    f1 = -> 0
    f2 = -> 1

    @authorizer.use(f1)
               .use(f2)
    test.strictEqual @authorizer.stack[0].handle, f1, "first function failed"
    test.strictEqual @authorizer.stack[1].handle, f2, "second function failed"
    test.done()

  "add middleware to the auth constructor": (test) ->
    f1 = -> 0
    f2 = -> 1

    @authorizer = span.createAuthorizer("SERVER", f1, f2)
    test.strictEqual @authorizer.stack[0].handle, f1, "first function failed"
    test.strictEqual @authorizer.stack[1].handle, f2, "second function failed"
    test.done()

  "middleware calling accept leads to acceptance": (test) ->
    @authorizer.use (agent, action, next) -> action.accept()
    @action.finished = =>
      @action.testAccepted(test)
      test.done()

    @authorizer @agent, @action

  "middleware calling reject then middleware calling accept leads to reject": (test) ->
    @authorizer.use (agent, action, next) -> 
      action.reject()
      next()
    @authorizer.use (agent, action) -> action.accept()
    @action.finished = =>
      @action.testRejected(test)
      test.done()

    @authorizer @agent, @action

  "middleware calling next will cause subsequent middleware to be called; middleware can modify agent & action": (test) ->
    @authorizer.use (agent, action, next) ->
      agent.newAttr = "first"
      next()
    @authorizer.use (agent, action, next) ->
      action.newAttr = "second"
      next()
    @action.finished = =>
      test.equal @agent.newAttr, "first"
      test.equal @action.newAttr, "second"
      test.done()

    @authorizer @agent, @action

  "middleware specified with a regexp will only run if matched; strings are converted to exact match regex": (test) ->
    @action.docName = "testing"
    @authorizer.use /debug/, (agent, action, next) ->
      agent.firstAttr = true
      next()
    @authorizer.use /test/, (agent, action, next) ->
      agent.secondAttr = true
      next()
    @authorizer.use "test", (agent, action, next) ->
      agent.thirdAttr = true
      next()
    @authorizer.use "testing", (agent, action, next) ->
      agent.fourthAttr = true
      next()
    @action.finished = =>
      test.strictEqual @agent.firstAttr, undefined
      test.strictEqual @agent.secondAttr, true
      test.strictEqual @agent.thirdAttr, undefined
      test.strictEqual @agent.fourthAttr, true
      test.done()

    @authorizer @agent, @action

  "middleware specified with a regexp will will be skipped in there is no action.docName": (test) ->
    @authorizer.use /debug/, (agent, action, next) ->
      agent.firstAttr = true
      next()
    @authorizer.use (agent, action, next) ->
      agent.secondAttr = true
      next()
    @action.finished = =>
      test.strictEqual @agent.firstAttr, undefined
      test.strictEqual @agent.secondAttr, true
      test.done()

    @authorizer @agent, @action

  "middleware attached with a TYPE will only run if match TYPE and if match regexp, if provided": (test) ->
    @action.type = "read"
    @action.docName = "testing"
    @authorizer.UPDATE (agent, action, next) ->
      agent.firstAttr = true
      next()
    @authorizer.READ (agent, action, next) ->
      agent.secondAttr = true
      next()
    @authorizer.READ "test", (agent, action, next) ->
      agent.thirdAttr = true
      next()
    @authorizer.READ "testing", (agent, action, next) ->
      agent.fourthAttr = true
      next()
    @action.finished = =>
      test.strictEqual @agent.firstAttr, undefined
      test.strictEqual @agent.secondAttr, true
      test.strictEqual @agent.thirdAttr, undefined
      test.strictEqual @agent.fourthAttr, true
      test.done()

    @authorizer @agent, @action

