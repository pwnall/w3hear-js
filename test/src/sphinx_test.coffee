# This is a node.js-only test that verifies that pocketsphinx.js presents the
# interface that we expect.

# Skip the sphinx.js tests in the browser.
if testSphinxLoader is null
  describe = -> null
else
  describe = W3hear._.global.describe

describe 'lib/sphinx/pocketsphinx.js', ->
  before ->
    @sphinx = testSphinxLoader._module

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

    describe 'constructor', ->
      it 'creates an empty vector', ->
        expect(@buffer.size()).to.equal 0

    describe '#get', ->
      it 'returns undefined when out of bounds', ->
        expect(@buffer.get(0)).to.equal undefined

    describe '#push_back', ->
      it 'works like the std::vector spec', ->
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

    describe '#set', ->
      beforeEach ->
        for i in [0...300]
          @buffer.push_back 0
          @buffer.push_back 0

      it 'works like the std::vector spec', ->
        for i in [0...300]
          @buffer.set i * 2, -i * 100
          @buffer.set i * 2 + 1, i * 100

        for i in [0...300]
          expect(@buffer.get(i * 2)).to.equal -i * 100
          expect(@buffer.get(i * 2 + 1)).to.equal i * 100

    describe '#resize', ->
      beforeEach ->
        for i in [0...300]
          @buffer.push_back i * 100
          @buffer.push_back -i * 100
        @buffer.push_back 42

      it 'shrinks the vector', ->
        @buffer.resize 300
        expect(@buffer.size()).to.equal 300
        for i in [0...150]
          expect(@buffer.get(i * 2)).to.equal i * 100
          expect(@buffer.get(i * 2 + 1)).to.equal -i * 100
        expect(@buffer.get(300)).to.equal undefined

      it 'grows the vector', ->
        @buffer.resize 620
        expect(@buffer.size()).to.equal 620
        for i in [0...300]
          expect(@buffer.get(i * 2)).to.equal i * 100
          expect(@buffer.get(i * 2 + 1)).to.equal -i * 100
        expect(@buffer.get(600)).to.equal 42
        for i in[601...620]
          expect([i, @buffer.get(i)]).to.deep.equal [i, 0]
        expect(@buffer.get(620)).to.equal undefined

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
      @config = new @sphinx.Config()
      @config.push_back ['-hmm', 'digits']
      @config.push_back ['-dict', 'digits.dic']
      @config.push_back ['-lm', 'digits.DMP']
      @recognizer = new @sphinx.Recognizer @config
    afterEach ->
      @recognizer.delete()
      @config.delete()

    describe '#addWords', ->
      beforeEach ->
        @words = new @sphinx.VectorWords()
        @words.push_back ['ZER', 'Z_zero II_zero R_zero']
        @words.push_back ['SEV', 'S_seven EH_seven V_seven']
        @status = @recognizer.addWords @words
      afterEach ->
        @words.delete()

      it 'succeeds with good data', ->
        expect(@status).to.equal @sphinx.ReturnType.SUCCESS

    describe '#addGrammar', ->
      beforeEach ->
        @transitions = new @sphinx.VectorTransitions()
        @transitions.push_back from: 0, to: 1, logp: 0, word: 'ZERO'
        @transitions.push_back from: 1, to: 2, logp: 0, word: 'SEVEN'
        @transitions.push_back from: 1, to: 2, logp: 0, word: ''

        @ids = new @sphinx.Integers()
        @status = @recognizer.addGrammar @ids,
            start: 1, end: 2, numStates: 3, transitions: @transitions

      afterEach ->
        @transitions.delete()
        @ids.delete()

      it 'succeeds with good data', ->
        expect(@status).to.equal @sphinx.ReturnType.SUCCESS

      it 'populates the ids input vector', ->
        expect(@ids.size()).to.equal 1

    describe '#addKeyword', ->
      beforeEach ->
        @ids = new @sphinx.Integers()
        @status = @recognizer.addKeyword @ids, 'ZERO ZERO SEVEN'

      afterEach ->
        @ids.delete()

      it 'succeeds with good data', ->
        expect(@status).to.equal @sphinx.ReturnType.SUCCESS

      it 'populates the ids input vector', ->
        expect(@ids.size()).to.equal 1

    describe '#switchSearch', ->
      beforeEach ->
        ids = new @sphinx.Integers()
        @recognizer.addKeyword ids, 'ZERO ZERO SEVEN'
        @keywordId = ids.get 0
        ids.delete()

        transitions = new @sphinx.VectorTransitions()
        transitions.push_back from: 0, to: 1, logp: 0, word: 'ZERO'
        transitions.push_back from: 1, to: 2, logp: 0, word: 'SEVEN'
        transitions.push_back from: 1, to: 2, logp: 0, word: ''
        ids = new @sphinx.Integers()
        @recognizer.addGrammar ids,
            start: 1, end: 2, numStates: 3, transitions: transitions
        @grammarId = ids.get 0
        ids.delete()
        transitions.delete()

      it 'works with a grammar', ->
        expect(@recognizer.switchSearch(@grammarId)).to.equal(
            @sphinx.ReturnType.SUCCESS)

      it 'works with a keyword', ->
        expect(@recognizer.switchSearch(@keywordId)).to.equal(
            @sphinx.ReturnType.SUCCESS)

    describe '#start / #process / #stop', ->
      beforeEach ->
        @silence = new @sphinx.AudioBuffer()
        for i in [0...1024]
          @silence.push_back 0
      afterEach ->
        @silence.delete()

      it 'works on silence', ->
        expect(@recognizer.start()).to.equal @sphinx.ReturnType.SUCCESS
        expect(@recognizer.process(@silence)).to.equal(
            @sphinx.ReturnType.SUCCESS)
        expect(@recognizer.getHyp()).to.equal ''
        expect(@recognizer.stop()).to.equal @sphinx.ReturnType.SUCCESS

