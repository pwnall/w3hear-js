# Skip the tests in the browser.
if testSphinxLoader is null
  describe = -> null
else
  describe = W3hear._.global.describe

describe 'Worker.SphinxDriver', ->
  before ->
    @driver = testSphinxLoader._driver

  it 'is loaded by testSphinxLoader', ->
    expect(@driver).to.be.an.instanceOf W3hearWorker.SphinxDriver

  describe 'with silence', ->
    beforeEach ->
      @shortSilence = [new Float32Array(512), new Float32Array(512)]
      @longSilence = [new Float32Array(2048), new Float32Array(2048)]

    it 'creates non-final results', ->
      @driver.process @shortSilence
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: false)
      # Buffer reuse opportunity.
      @driver.process @shortSilence
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: false)
      # No buffer reuse possible.
      @driver.process @longSilence
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: false)

    it 'creates final results', ->
      @driver.process @shortSilence
      @driver.stop()
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: true)
      # Buffer reuse opportunity.
      @driver.process @shortSilence
      @driver.stop()
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: true)
      # No buffer reuse possible.
      @driver.process @longSilence
      @driver.stop()
      expect(@driver.result(false)).to.deep.equal(
          text: '', conf: 0, final: true)

    it 'reallocates the samples buffer when necessary', ->
      @driver.process @shortSilence
      expect(@driver._buffer.size()).to.equal 512
      oldBuffer = @driver._buffer
      @driver.process @longSilence
      expect(@driver._buffer.size()).to.equal 2048
      expect(@driver._buffer).not.to.equal oldBuffer

    it 'reuses the samples buffer when possible', ->
      @driver.process @shortSilence
      expect(@driver._buffer.size()).to.equal 512
      oldBuffer = @driver._buffer

      for i in [0...512]
        @shortSilence[0][i] = -1 + 2 * (i % 2)
      @driver.process @shortSilence
      expect(@driver._buffer.size()).to.equal 512
      expect(@driver._buffer).to.equal oldBuffer
      for i in [0...512]
        expect(@driver._buffer.get(i)).to.equal @shortSilence[0][i]

