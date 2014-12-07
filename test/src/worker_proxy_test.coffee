WorkerProxy = W3hear._.WorkerProxy

# HACK: skip all the tests in node.js
if W3hear._.Worker is null
  describe = -> null
else
  describe = W3hear._.global.describe

describe 'WorkerProxy', ->
  before ->
    if testXhrServer is ''
      fs = require 'fs'
      path = require 'path'
      @path = path.join __dirname, '..', '..', 'lib'
    else
      @path = testXhrServer + '/lib'

  describe 'sphinx with debugging', ->
    before (done) ->
      @infos = []
      @errors = []
      @proxy = new WorkerProxy(
          workerPath: @path, engine: 'sphinx', modelData: 'digits',
          engineDebug: true)
      @proxy.debugLog = (level, message) =>
        if level is 'info'
          @infos.push message
        else if level is 'error'
          @errors.push message
        else
          expect("Invalid debug logging level: #{level}").to.equal null
      @proxy.onReady.addListener ->
        done()

    after ->
      @proxy.terminate()

    it 'logs at least one error message', ->
      expect(@errors.length).to.be.at.least 1

