# This is a node.js-only test that verifies that pocketsphinx.js presents the
# interface that we expect.

fs = require 'fs'

describe 'lib/sphinx/pocketsphinx.js', ->
  before ->
    # Massive hack for loading the asm.js code.
    sphinxJs = fs.readFileSync 'lib/sphinx/pocketsphinx.js', encoding: 'utf8'
    digitsJs = fs.readFileSync 'lib/sphinx/models/digits.js', encoding: 'utf8'
    Module = null
    eval(sphinxJs + ";\n" + digitsJs)
    @sphinx = Module

  it 'defines the right APIs', ->
    # The API list is extracted from the pocketsphinx.js README.
    #     https://github.com/syl22-00/pocketsphinx.js#3-api-of-pocketsphinxjs
    expect(@sphinx).to.have.property 'AudioBuffer'
    expect(@sphinx).to.have.property 'Config'
    expect(@sphinx).to.have.property 'Integers'
    expect(@sphinx).to.have.property 'Recognizer'
    expect(@sphinx).to.have.property 'ReturnType'
    expect(@sphinx).to.have.property 'Segmentation'
    expect(@sphinx).to.have.property 'VectorTransitions'
    expect(@sphinx).to.have.property 'VectorWords'

  describe 'ReturnType', ->
    it 'defines SUCCESS', ->
      expect(@sphinx.ReturnType).to.have.property 'SUCCESS'
    it 'defines BAD_STATE', ->
      expect(@sphinx.ReturnType).to.have.property 'BAD_STATE'
    it 'defines BAD_ARGUMENT', ->
      expect(@sphinx.ReturnType).to.have.property 'BAD_ARGUMENT'
    it 'defines RUNTIME_ERROR', ->
      expect(@sphinx.ReturnType).to.have.property 'RUNTIME_ERROR'

  describe 'AudioBuffer', ->
    beforeEach ->
      @buffer = new @sphinx.AudioBuffer()
    afterEach ->
      @buffer.delete()

    it 'works like a std::vector of shorts', ->
      expect(@buffer.size()).to.equal 0

      for i in [0...300]
        @buffer.push_back i * 100
        @buffer.push_back -i * 100
      @buffer.push_back 42
      expect(@buffer.size()).to.equal 601

      for i in [0...300]
        expect(@buffer.get(i * 2)).to.equal i * 100
        expect(@buffer.get(i * 2 + 1)).to.equal -i * 100
      expect(@buffer.get(600)).to.equal 42

      expect(@buffer.get(601)).to.equal undefined

  describe 'Config', ->
    beforeEach ->
      @config = new @sphinx.Config()
    afterEach ->
      @config.delete()

    it 'works like a std::vector of string pairs', ->
      expect(@config.size()).to.equal 0

      @config.push_back ['-hmm', 'en']
      expect(@config.size()).to.equal 1
      expect(@config.get(0)[0]).to.equal '-hmm'
      expect(@config.get(0)[1]).to.equal 'en'

      expect(@config.get(1)).to.equal undefined

  describe 'Integers', ->
    beforeEach ->
      @vector = new @sphinx.Integers()
    afterEach ->
      @vector.delete()

    it 'works like a std::vector of ints', ->
      expect(@vector.size()).to.equal 0

      for i in [0...300]
        @vector.push_back i * 10000
        @vector.push_back -i * 10000
      @vector.push_back 424242
      expect(@vector.size()).to.equal 601

      for i in [0...300]
        expect(@vector.get(i * 2)).to.equal i * 10000
        expect(@vector.get(i * 2 + 1)).to.equal -i * 10000
      expect(@vector.get(600)).to.equal 424242

      expect(@vector.get(601)).to.equal undefined

  describe 'Segmentation', ->
    beforeEach ->
      @segmentation = new @sphinx.Segmentation()
    afterEach ->
      @segmentation.delete()

    it 'works like a std::vector of structs', ->
      expect(@segmentation.size()).to.equal 0

      @segmentation.push_back start: 12, end: 13, word: 'hello world!'
      expect(@segmentation.size()).to.equal 1
      expect(@segmentation.get(0).start).to.equal 12
      expect(@segmentation.get(0).end).to.equal 13
      expect(@segmentation.get(0).word).to.equal 'hello world!'

      expect(@segmentation.get(1)).to.equal undefined

  describe 'VectorTransitions', ->
    beforeEach ->
      @vector = new @sphinx.VectorTransitions()
    afterEach ->
      @vector.delete()

    it 'works like a std::vector of structs', ->
      expect(@vector.size()).to.equal 0

      @vector.push_back from: 12, to: 13, logp: 0, word: 'HELLO'
      expect(@vector.size()).to.equal 1
      expect(@vector.get(0).from).to.equal 12
      expect(@vector.get(0).to).to.equal 13
      expect(@vector.get(0).logp).to.equal 0
      expect(@vector.get(0).word).to.equal 'HELLO'

      expect(@vector.get(1)).to.equal undefined

  describe 'VectorWords', ->
    beforeEach ->
      @vector = new @sphinx.VectorWords()
    afterEach ->
      @vector.delete()

    it 'works like a std::vector of string pairs', ->
      expect(@vector.size()).to.equal 0

      @vector.push_back ['HELLO', 'HH AH L OW']
      expect(@vector.size()).to.equal 1
      expect(@vector.get(0)[0]).to.equal 'HELLO'
      expect(@vector.get(0)[1]).to.equal 'HH AH L OW'

      expect(@vector.get(1)).to.equal undefined


  describe 'Recognizer', ->
    beforeEach ->
      @recognizer = new @sphinx.Recognizer()
    afterEach ->
      @recognizer.delete()
