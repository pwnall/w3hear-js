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

  describe 'with stubs', ->
    # NOTE: sphinx_test.coffee has tests for the actual Module interface; as
    #       long as those pass, there is some assurance that the stub
    #       implementation here is accurate
    beforeEach ->
      # Stub for the embind std::vector interface.
      vector = class CVector
        constructor: ->
          @_length = 0
          @_deleted = false
          @_data = []
        push_back: (e) ->
          # HACK(pwnall): simulate the AudioBuffer rounding
          e = Math.floor(e) if typeof e is 'number'
          @_data[@_length] = e
          @_length += 1
        get: (i) -> @_data[i]
        set: (i, e) ->
          # HACK(pwnall): simulate the AudioBuffer rounding
          e = Math.floor(e) if typeof e is 'number'
          @_data[i] = e
        size: -> @_length
        resize: (s, e) ->
          expect(e).to.equal 0
          @_data.splice s
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

    describe '#_resample', ->
      describe 'with a 1/1 ratio', ->
        beforeEach ->
          @driver = new SphinxDriver @module, model: 'klingon', rate: 16000

        it 'scales correctly', ->
          samples = [new Float32Array(9), new Float32Array(9)]
          source = [1, 0.75, 0.5, 0.25, 0, -0.25, -0.5, -0.75, -1]
          for i in [0...9]
            samples[0][i] = source[i]
            samples[1][i] = source[i]

          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [32766, 24574, 16383, 8191, 0, -8192, -16383, -24575, -32766])

        it 'mixes the channels correctly', ->
          samples = [new Float32Array(9), new Float32Array(9)]
          source = [1, 0.75, 0.5, 0.25, 0, -0.25, -0.5, -0.75, -1]
          for i in [0...9]
            samples[0][i] = source[i]
            samples[1][i] = -source[i]

          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [0, 0, 0, 0, 0, 0, 0, 0, 0])

        it 'has correct push_back and set write methods', ->
          samples = [new Float32Array(9), new Float32Array(9)]
          source = [1, 0.75, 0.5, 0.25, 0, -0.25, -0.5, -0.75, -1]

          # Test the push_back write method.
          for i in [0...9]
            samples[0][i] = source[i]
            samples[1][i] = source[i]
          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [32766, 24574, 16383, 8191, 0, -8192, -16383, -24575, -32766])
          oldBuffer = @driver._buffer

          # Test the set write method.
          for i in [0...9]
            samples[0][i] = source[i]
            samples[1][i] = -source[i]
          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [0, 0, 0, 0, 0, 0, 0, 0, 0])
          expect(@driver._buffer).to.equal oldBuffer

        it 'grows the buffer when necessary', ->
          source = [1, 0.75, 0.5, 0.25, 0, -0.25, -0.5, -0.75, -1]

          samples = [new Float32Array(4), new Float32Array(4)]
          for i in [0...4]
            samples[0][i] = source[5 + i]
            samples[1][i] = source[5 + i]
          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [-8192, -16383, -24575, -32766])
          oldBuffer = @driver._buffer

          samples = [new Float32Array(9), new Float32Array(9)]
          for i in [0...9]
            samples[0][i] = source[i]
            samples[1][i] = source[i]
          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [32766, 24574, 16383, 8191, 0, -8192, -16383, -24575, -32766])
          expect(@driver._buffer).to.equal oldBuffer

        it 'shrinks the buffer when necessary', ->
          source = [1, 0.75, 0.5, 0.25, 0, -0.25, -0.5, -0.75, -1]

          samples = [new Float32Array(9), new Float32Array(9)]
          for i in [0...9]
            samples[0][i] = source[i]
            samples[1][i] = source[i]
          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [32766, 24574, 16383, 8191, 0, -8192, -16383, -24575, -32766])
          oldBuffer = @driver._buffer

          samples = [new Float32Array(4), new Float32Array(4)]
          for i in [0...4]
            samples[0][i] = source[5 + i]
            samples[1][i] = source[5 + i]
          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [-8192, -16383, -24575, -32766])
          expect(@driver._buffer).to.equal oldBuffer

      describe 'with a 3/2 ratio', ->
        beforeEach ->
          @driver = new SphinxDriver @module, model: 'klingon', rate: 24000

        it 'resamples correctly without carryover', ->
          samples = [new Float32Array(9), new Float32Array(9)]
          source = [1, 1, 1, -1, -1, -1, 1, 1, 1]
          for i in [0...9]
            samples[0][i] = source[i]
            samples[1][i] = source[i]

          # Test the push_back branch.
          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [32766, 32766, -32766, -32766, 32766, 32766])

          # Test the set branch.
          for i in [0...9]
            samples[0][i] = -source[i]
            samples[1][i] = -source[i]
          @driver._resample samples
          expect(@driver._buffer._data).to.deep.equal(
              [-32766, -32766, 32766, 32766, -32766, -32766])

