# Skip the tests in the browser.
if testSphinxLoader is null
  describe = -> null
else
  describe = W3hear._.global.describe
  SphinxDriver = W3hearWorker.SphinxDriver

describe 'Worker.SphinxDriver', ->
  beforeEach ->
    @driver = testSphinxLoader._driver

  it 'is loaded by testSphinxLoader', ->
    expect(@driver).to.be.an.instanceOf SphinxDriver

  describe 'with silence', ->
    beforeEach ->
      @silence = [new Float32Array(512), new Float32Array(512)]
      @driver.stop()

    it 'creates non-final results', ->
      @driver.process @silence
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: false)
      @driver.process @silence
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: false)
      @driver.process @silence
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: false)

    it 'creates final results', ->
      @driver.process @silence
      @driver.stop()
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: true)
      @driver.process @silence
      @driver.stop()
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: true)

    it 'transforms the data correctly', ->
      @driver.process @silence
      expect(@driver._buffer.size()).to.equal 512
      for i in [0...512]
        expect([i, @driver._buffer.get(i)]).to.deep.equal([i, 0])
      oldBuffer = @driver._buffer

      for i in [0...512]
        @silence[0][i] = -1 + 2 * (i % 2)
        @silence[1][i] = -1 + 2 * (i % 2)
      @driver.process @silence
      expect(@driver._buffer.size()).to.equal 512
      expect(@driver._buffer).to.equal oldBuffer
      for i in [0...512]
        expect([i, @driver._buffer.get(i)]).to.deep.equal(
            [i, -32766 + 65532 * (i % 2)])

  describe.only 'with stubs', ->
    beforeEach ->
      # Stub for the embind std::vector interface.
      vector = class CVector
        constructor: ->
          @_length = 0
          @_deleted = false
          @_data = []
        push_back: (e) ->
          @_data[@_length] = e
          @_length += 1
        get: (i) -> @_data[i]
        set: (i, e) -> @_data[i] = e
        size: -> @_length
        delete: ->
          @_deleted = true
          @_data = null  # Catch use-after-delete.
      # Stub for the Recognizer embind interface.
      recognizer = class CRecognizer
        constructor: (@_config) ->
          null

      @module = {
        ReturnType: { SUCCESS: 'success' },
        Config: vector,
        AudioBuffer: vector
        Recognizer: recognizer
      }
      @driver = new SphinxDriver @module, model: 'klingon', rate: 44100

    describe 'constructor', ->
      it 'sets the config correctly', ->
        expect(@driver._config).to.be.an.instanceOf @module.Config
        expect(@driver._config._data).to.deep.equal(
          [
            ['-hmm', 'klingon'],
            ['-dict', 'klingon.dic'],
            ['-lm', 'klingon.DMP']
          ])

      it 'creates the recognizer correctly', ->
        expect(@driver._recognizer).to.be.an.instanceOf @module.Recognizer
        expect(@driver._recognizer._config).to.equal @driver._config

      it 'initializes the resampler correctly', ->
        expect(@driver._inRate).to.equal 44100
        expect(@driver._outRate).to.equal 16000

    describe '#resample', ->
      describe 'with a 3/2 ratio', ->
        beforeEach ->
          @driver = new SphinxDriver @module, model: 'klingon', rate: 24000

        it 'resamples correctly without carryover', ->
          samples = [new Float32Array(9), new Float32Array(9)]
          # [1, 1, 1, -1, -1, -1, 1, 1, 1]
          for i in [0...9]
            samples[0][i] = -1 + 2 * (i % 2)
            samples[1][i] = -1 + 2 * (i % 2)

          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [])
