# This is a node.js-only test that verifies that the
# interface that we expect.

# Skip the tests in the browser.
if typeof W3hearWorker is 'undefined'
  describe = -> null
  Driver = null
else
  describe = W3hearWorker.global.describe
  Driver = W3hearWorker.Driver

describe 'Worker.Driver', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @module = { a: 'module' }
    @samples = [[0], [0]]
    @driver = new Driver @module, null

  afterEach ->
    @sandbox.restore()

  describe '.modelDataFile', ->
    it 'throws', ->
      expect(-> Driver.modelDataFile('en')).to.throw(Error, /not implemented/i)

  describe '.engineFile', ->
    it 'is null', ->
      expect(Driver.engineFile).to.equal null

  describe '#_process', ->
    it 'throws', ->
      expect(=> @driver._process(@samples)).to.throw(Error, /not implemented/i)

  describe '#_result', ->
    it 'throws', ->
      expect(=> @driver._result()).to.throw(Error, /not implemented/i)

  describe '#result', ->
    describe 'when #_result returns the same result', ->
      beforeEach ->
        stub = @sandbox.stub @driver, '_result'
        stub.withArgs().returns text: 'hello', conf: 0.42
        stub.throws 'TypeError'

      describe 'with nullIfStale', ->
        it 'reports the correct result the first time', ->
          expect(@driver.result(true)).to.deep.equal(
              text: 'hello', conf: 0.42, final: true)

        it 'does not report stale results', ->
          expect(@driver.result(true)).to.deep.equal(
              text: 'hello', conf: 0.42, final: true)
          expect(@driver.result(true)).to.equal null
          expect(@driver.result(true)).to.equal null

      describe 'without nullIfStale', ->
        it 'reports the correct result the first time', ->
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello', conf: 0.42, final: true)

        it 'reports stale results', ->
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello', conf: 0.42, final: true)
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello', conf: 0.42, final: true)
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello', conf: 0.42, final: true)

    describe 'when #_result returns different results', ->
      beforeEach ->
        stub = @sandbox.stub @driver, '_result'
        stub.onCall(0).returns text: 'hello', conf: 0.42
        stub.onCall(1).returns text: 'hello world', conf: 0.25
        stub.returns text: 'hello world', conf: 0.42

      describe 'with nullIfStale', ->
        it 'reports fresh results, does not report stale results', ->
          expect(@driver.result(true)).to.deep.equal(
              text: 'hello', conf: 0.42, final: true)
          expect(@driver.result(true)).to.deep.equal(
              text: 'hello world', conf: 0.25, final: true)
          expect(@driver.result(true)).to.deep.equal(
              text: 'hello world', conf: 0.42, final: true)
          expect(@driver.result(true)).to.equal null
          expect(@driver.result(true)).to.equal null

      describe 'without nullIfStale', ->
        it 'reports stale results', ->
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello', conf: 0.42, final: true)
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello world', conf: 0.25, final: true)
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello world', conf: 0.42, final: true)
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello world', conf: 0.42, final: true)
          expect(@driver.result(false)).to.deep.equal(
              text: 'hello world', conf: 0.42, final: true)

  describe '#process, #stop', ->
    beforeEach ->
      @driver._start = =>
        expect(@driver._started).to.equal false
      @driver._process = (samples) =>
        expect(@driver._started).to.equal true
        expect(samples).to.equal @samples
      @driver._stop = =>
        expect(@driver._started).to.equal true

      @startSpy = @sandbox.spy @driver, '_start'
      @stopSpy = @sandbox.spy @driver, '_stop'
      @processSpy = @sandbox.spy @driver, '_process'

    it 'start the engine before giving it samples', ->
      expect(@driver._started).to.equal false

      @driver.process @samples
      expect(@startSpy.callCount).to.equal 1
      expect(@processSpy.callCount).to.equal 1
      expect(@stopSpy.callCount).to.equal 0
      expect(@driver._started).to.equal true

    it 'do not re-start the engine while feeding it samples', ->
      expect(@driver._started).to.equal false

      @driver.process @samples
      expect(@startSpy.callCount).to.equal 1
      expect(@processSpy.callCount).to.equal 1
      expect(@stopSpy.callCount).to.equal 0
      expect(@driver._started).to.equal true

      @driver.process @samples
      expect(@startSpy.callCount).to.equal 1
      expect(@processSpy.callCount).to.equal 2
      expect(@stopSpy.callCount).to.equal 0

    it 're-start the engine after it gets stopped', ->
      expect(@driver._started).to.equal false

      @driver.process @samples
      expect(@startSpy.callCount).to.equal 1
      expect(@processSpy.callCount).to.equal 1
      expect(@stopSpy.callCount).to.equal 0
      expect(@driver._started).to.equal true

      @driver.stop()
      expect(@startSpy.callCount).to.equal 1
      expect(@processSpy.callCount).to.equal 1
      expect(@stopSpy.callCount).to.equal 1
      expect(@driver._started).to.equal false

      @driver.process @samples
      expect(@startSpy.callCount).to.equal 2
      expect(@processSpy.callCount).to.equal 2
      expect(@stopSpy.callCount).to.equal 1
      expect(@driver._started).to.equal true

    it 'do not stop the engine when it is already stopped', ->
      @driver.process @samples
      expect(@startSpy.callCount).to.equal 1
      expect(@processSpy.callCount).to.equal 1
      expect(@stopSpy.callCount).to.equal 0
      expect(@driver._started).to.equal true

      @driver.stop()
      expect(@startSpy.callCount).to.equal 1
      expect(@processSpy.callCount).to.equal 1
      expect(@stopSpy.callCount).to.equal 1
      expect(@driver._started).to.equal false

      @driver.stop()
      expect(@startSpy.callCount).to.equal 1
      expect(@processSpy.callCount).to.equal 1
      expect(@stopSpy.callCount).to.equal 1
      expect(@driver._started).to.equal false
