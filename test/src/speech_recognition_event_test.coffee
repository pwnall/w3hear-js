SpeechRecognitionEvent = W3hear.SpeechRecognitionEvent
SpeechRecognitionResultList = W3hear.SpeechRecognitionResultList
SpeechRecognitionResult = W3hear.SpeechRecognitionResult
SpeechRecognitionAlternative = W3hear.SpeechRecognitionAlternative

describe 'SpeechRecongitionResultList', ->
  describe 'with a final result', ->
    beforeEach ->
      @message =
          type: 'result',
          result: { final: true, conf: 0.42, text: 'hello world' }
      @list = new SpeechRecognitionResultList @message

    it 'has length 1', ->
      expect(@list.length).to.equal 1

    it 'returns the same result from valid subscripting and indexing', ->
      expect(@list.item(0)).to.equal @list[0]

    it 'returns undefined from invalid subscripting', ->
      expect(@list[1]).to.equal undefined

    it 'returns undefined from invalid indexing', ->
      expect(@list.item(1)).to.equal undefined

    describe '[0]', ->
      it 'is a SpeechRecognitionResult', ->
        expect(@list[0]).to.be.ok
        expect(@list[0]).to.be.an.instanceOf SpeechRecognitionResult

      it 'is final', ->
        expect(@list[0].isFinal).to.equal true

      it 'has one alternative', ->
        expect(@list[0].length).to.equal 1
        expect(@list[0][0]).to.be.ok
        expect(@list[0][0]).to.be.an.instanceOf SpeechRecognitionAlternative

      it 'has the correct data in the alternative', ->
        expect(@list[0][0].transcript).to.equal 'hello world'
        expect(@list[0][0].confidence).to.equal 0.42

  describe 'with a non-final result', ->
    beforeEach ->
      @message =
          type: 'result',
          result: { final: false, conf: 0.25, text: 'hello' }
      @list = new SpeechRecognitionResultList @message

    it 'has length 1', ->
      expect(@list.length).to.equal 1

    it 'returns the same result from valid subscripting and indexing', ->
      expect(@list.item(0)).to.equal @list[0]

    it 'returns undefined from invalid subscripting', ->
      expect(@list[1]).to.equal undefined

    it 'returns undefined from invalid indexing', ->
      expect(@list.item(1)).to.equal undefined

    describe '[0]', ->
      it 'is a SpeechRecognitionResult', ->
        expect(@list[0]).to.be.ok
        expect(@list[0]).to.be.an.instanceOf SpeechRecognitionResult

      it 'is not final', ->
        expect(@list[0].isFinal).to.equal false

      it 'has one alternative', ->
        expect(@list[0].length).to.equal 1
        expect(@list[0][0]).to.be.ok
        expect(@list[0][0]).to.be.an.instanceOf SpeechRecognitionAlternative

      it 'has the correct data in the alternative', ->
        expect(@list[0][0].transcript).to.equal 'hello'
        expect(@list[0][0].confidence).to.equal 0.25


describe 'SpeechRecognitionEvent', ->
  describe 'with a result list', ->
    beforeEach ->
      @message =
          type: 'result',
          result: { final: true, conf: 0.42, text: 'hello world' }
      @list = new SpeechRecognitionResultList @message
      @target = { an: 'object' }

      @event = new SpeechRecognitionEvent @list, @target

    it 'saves the result list', ->
      expect(@event.results).to.equal @list

    it 'saves the target', ->
      expect(@event.target).to.equal @target
