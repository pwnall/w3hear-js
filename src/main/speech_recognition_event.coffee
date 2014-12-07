# Fired when a speech recognition result is available.
class W3hear.SpeechRecognitionEvent
  # Creates an event for a speech recognition result.
  #
  # @private
  # This should only be called by the W3hear implementation.
  #
  # @param {W3hear.SpeechRecognitionResultList} results the speech recognition
  #   engine's hypothesis
  # @param {W3hear} target the recognizer that generated this event
  constructor: (results, target) ->
    @results = results
    @target = target

  # @property {W3hear.SpeechRecognitionResultList} the speech recognition
  #   engine's hypothesis
  results: null

  # @property {W3hear} the recognizer that generated this event
  target: null

# A hypothesis returned from the speech recognition engine.
class W3hear.SpeechRecognitionResultList
  # Creates a speech recognition engine hypothesis.
  #
  # @private
  # This should only be called by the W3hear implementation.
  #
  # @param {Object} data a message received from the Web worker hosting the
  #   speech recognition engine
  constructor: (data) ->
    result = new W3hear.SpeechRecognitionResult data.result
    @length = 1
    @[0] = result

  # Alternative array access method.
  #
  # @param {Number} index the desired alternative
  # @return {W3hear.SpeechRecognitionAlternative} the requested alternative
  item: (index) ->
    return undefined unless typeof index is 'number'
    @[index]

  # @property {Number} the number of results
  length: null

# A result returned from the speech recognition engine.
class W3hear.SpeechRecognitionResult
  # Creates a speech recognition engine result.
  #
  # @private
  # This should only be called by the W3hear implementation.
  #
  # @param {Object} result a result received from the Web worker hosting the
  #   speech recognition engine
  constructor: (result) ->
    alternative = new W3hear.SpeechRecognitionAlternative result
    @isFinal = result.final
    @length = 1
    @[0] = alternative

  # Alternative array access method.
  #
  # @param {Number} index the desired alternative
  # @return {W3hear.SpeechRecognitionAlternative} the requested alternative
  item: (index) ->
    return undefined unless typeof index is 'number'
    @[index]

  # @property {Boolean} set to true when the speech ended
  isFinal: null

  # @property {Number} the number of alternatives
  length: null

# One speech recognition hypothesis.
class W3hear.SpeechRecognitionAlternative
  # Creates a speech recognition engine result alternative.
  #
  # @private
  # This should only be called by the W3hear implementation.
  #
  # @param {Object} result a result received from the Web worker hosting the
  #   speech recognition engine
  constructor: (result) ->
    @transcript = result.text
    @confidence = result.conf

  # @property {String}
  transcript: null

  # @property {Number}
  confidence: null
