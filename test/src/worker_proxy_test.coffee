WorkerProxy = W3hear._.WorkerProxy

describe 'WorkerProxy interface', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @realWorkerClass = W3hear._.Worker
    W3hear._.Worker = class WorkerStub
      constructor: (@_url) ->
        @_messages = []
        @_terminated = false
      postMessage: (message) ->
        @_messages.push message
      termianate: ->
        @_terminated = true

  afterEach ->
    @sandbox.restore()
    W3hear._.Worker = @realWorkerClass

  describe 'constructor', ->
    it 'uses w3hear_proxy.js as the default filename', ->
      @proxy = new WorkerProxy { sampleRate: 44100 },
          workerPath: 'http://example.com/path/'
      expect(@proxy._worker._url).to.equal(
          'http://example.com/path/w3hear_worker.js')

    it 'obeys the workerFile option', ->
      @proxy = new WorkerProxy { sampleRate: 44100 },
          { workerPath: 'http://example.com/path/', workerFile: 'other.js' }
      expect(@proxy._worker._url).to.equal 'http://example.com/path/other.js'

    it 'adds trailing / to workerPath', ->
      @proxy = new WorkerProxy { sampleRate: 44100 },
          workerPath: 'http://example.com/path'
      expect(@proxy._worker._url).to.equal(
          'http://example.com/path/w3hear_worker.js')
      @proxy = new WorkerProxy { sampleRate: 44100 },
          { workerPath: 'http://example.com/path', workerFile: 'other.js' }
      expect(@proxy._worker._url).to.equal 'http://example.com/path/other.js'

    it 'sends good defaults to boot the worker', ->
      @proxy = new WorkerProxy { sampleRate: 12345 }, workerPath: '/path'
      expect(@proxy._worker._messages).to.have.length 1
      expect(@proxy._worker._messages[0]).to.deep.equal(
          type: 'boot', path: '/path/', engine: 'sphinx', model: 'en',
          debug: false, rate: 12345, modelRate: null)

    it 'uses given options to boot the worker', ->
      @proxy = new WorkerProxy { sampleRate: 54321 },
          workerPath: 'http://example.com/path', engine: 'blitzcrank',
          modelData: 'klingon', engineDebug: true, modelRate: 4321
      expect(@proxy._worker._messages).to.have.length 1
      expect(@proxy._worker._messages[0]).to.deep.equal(
          type: 'boot', path: 'http://example.com/path/', engine: 'blitzcrank',
          model: 'klingon', debug: true, rate: 54321, modelRate: 4321)
