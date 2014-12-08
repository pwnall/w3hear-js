WorkerProxy = W3hear._.WorkerProxy

# Skip the live tests in node.js for now. We may reconsider this decision
# if we find a stable Web Worker polyfill.
if W3hear._.Worker is null
  describe = -> null
else
  describe = W3hear._.global.describe

describe 'WorkerProxy integration', ->
  before ->
    @path = testXhrServer + '/lib'

  describe 'sphinx with debugging', ->
    before (done) ->
      @infos = []
      @errors = []
      @proxy = new WorkerProxy({ sampleRate: 44100 },
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

    describe 'with silence samples', ->
      it '#sendSamples generates one non-final and one final prediction',
          (done) ->
            gotNonFinal = false
            gotFinal = false
            @proxy.onResult = (results) =>
              expect(results.length).to.equal 1
              expect(results[0].length).to.equal 1
              expect(results[0][0].transcript).to.equal ''
              expect(results[0][0].confidence).to.equal 0
              expect(gotFinal).to.equal false
              if gotNonFinal is false
                expect(results[0].isFinal).to.equal false
                gotNonFinal = true
              else
                expect(results[0].isFinal).to.equal true
                gotFinal = true
                done()
            for i in [0...3]
              shortSilence = [new Float32Array(512), new Float32Array(512)]
              @proxy.sendSamples shortSilence
            @proxy.requestResult()
