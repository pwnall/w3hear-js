# Skipping worker tests in node.js for now. We may reconsider this decision if
# we find a stable Web Worker polyfill.
if W3hear._.Worker is null
  describe = -> null
else
  describe = W3hear._.global.describe

describe 'W3hear', ->
  beforeEach ->
    @path = testXhrServer + '/lib'
    @w3hear = new W3hear(
        workerPath: @path, engine: 'sphinx', modelData: 'digits',
        engineDebug: true)

  afterEach ->
    @w3hear.stop()
    @w3hear._proxy._worker.terminate()
    @w3hear._capture.release()

  describe 'with a mock error', ->
    beforeEach ->
      # WebRTC requires user interaction, replace it with a static stream.
      @error = { an: 'error' }
      @w3hear._acquireStream = =>
        setTimeout (=> @w3hear._onStreamAcqError(@error)), 0

    it 'reports the error', (done) ->
      @w3hear.onerror = (error) =>
        expect(error).to.equal @error
        done()
      @w3hear.start()

  describe 'with a silence mock stream', ->
    beforeEach ->
      # WebRTC requires user interaction, replace it with a static stream.
      @w3hear._acquireStream = =>
        # NOTE: MediaStream is unstable in Chrome, but we only need it to
        #       produce silence; it usually does that, so it doesn't break this
        #       test
        context = new W3hear._.AudioContext()
        buffer = context.createBuffer 2, 44100, 44100
        for ch in [0...2]
          data = buffer.getChannelData ch
          for i in [0...data.length]
            data[i] = 0
        source = context.createBufferSource()
        source.buffer = buffer
        source.loop = false
        destination = context.createMediaStreamDestination()
        source.connect destination
        stream = destination.stream
        @w3hear._onStreamAcquisition stream
        source.start context.currentTime, 0

    it 'generates a non-final result', (done) ->
      @w3hear.onresult = (event) =>
        expect(event).to.be.ok
        expect(event).to.be.an.instanceOf W3hear.SpeechRecognitionEvent
        expect(event.results.length).to.equal 1
        expect(event.results[0].length).to.equal 1
        expect(event.results[0].isFinal).to.equal false
        expect(event.results[0][0].transcript).to.equal ''
        done()
      @w3hear.start()

    it 'generates a final result', (done) ->
      @w3hear.onresult = (event) =>
        expect(event).to.be.ok
        expect(event).to.be.an.instanceOf W3hear.SpeechRecognitionEvent
        expect(event.results.length).to.equal 1
        expect(event.results[0].length).to.equal 1
        expect(event.results[0].isFinal).to.equal false
        expect(event.results[0][0].transcript).to.equal ''
        @w3hear.onresult = (event) =>
          expect(event).to.be.ok
          expect(event).to.be.an.instanceOf W3hear.SpeechRecognitionEvent
          expect(event.results.length).to.equal 1
          expect(event.results[0].length).to.equal 1
          return unless event.results[0].isFinal is true
          expect(event.results[0].isFinal).to.equal true
          expect(event.results[0][0].transcript).to.equal ''
          expect(@w3hear._started).to.equal false
          expect(@w3hear._wantFinalResult).to.equal false
          done()
        @w3hear.stop()
        expect(@w3hear._started).to.equal false
        expect(@w3hear._wantFinalResult).to.equal true
      @w3hear.start()

