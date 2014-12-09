# The entry point to speech recognition functionality.
class W3hear
  # Instantiates the speech recognition system.
  #
  # This is a very heavyweight class. It brings in a Web Worker that loads and
  # runs anywhere from 2 to 100Mb of JS code, and a Web Audio graph. It should
  # really only be instantiated once.
  #
  # @param {Object} options point to the main Web Worker JS file, and customize
  #   the speech recognition system
  constructor: (options) ->
    options ||= {}
    @_stream = null
    @_capture = new W3hear._.Capture options
    system = sampleRate: @_capture.sampleRate()
    @_proxy = new W3hear._.WorkerProxy system, options
    @_proxy.onResult = @_onWorkerResult.bind(@)
    # NOTE: the Capture object only generates samples when started, so we don't
    #       need to worry about posting useless messages to the Web Worker
    @_capture.onSamples = @_proxy.sendSamples.bind(@_proxy)
    @_started = false
    @_wantFinalResult = false

  # Start processing microphone input.
  #
  # This method call is ignored if the recognizer has already been started.
  #
  # @return undefined
  start: ->
    return if @_started is true
    @_started = true
    if @_stream is null
      @_acquireStream()
    else
      @_capture.start @_stream
    return

  # Stops processing microphone input and report the final hypothesis.
  #
  # This method call is ignored if the recognizer has not been started, or has
  # already been stopped.
  #
  # @return undefined
  stop: ->
    return if @_started is false
    @_started = false
    @_wantFinalResult = true
    @_capture.stop()
    @_proxy.requestResult()
    return

  # Asks the user for microphone access permission.
  #
  # @private
  # This is called by {#start} as necessary.
  #
  # This will call {#_onStreamAcquisition} if everything goes well, or
  # {#_onStreamAcqError} if the user denies permission.
  #
  # @return undefined
  _acquireStream: ->
    W3hear._.getUserMedia { audio: true }, @_onStreamAcquisition.bind(@),
                                           @_onStreamAcqError.bind(@)
    return

  # Called when the user grants us microphone access.
  #
  # @param {MediaStream} stream a MediaStream with microphone data
  # @return undefined
  _onStreamAcquisition: (stream) ->
    if @_stream isnt null
      throw new Error("Doubly-acquired microphone MediaStream")
    @_stream = stream
    if @_started
      # NOTE: the user might have canceled the recognition
      @_capture.start @_stream
    return

  # Called when we're not getting microphone access.
  #
  # @param {Error} error some information about what happened
  # @return undefined
  _onStreamAcqError: (error) ->
    if @onerror isnt null
      @onerror error
    return

  # Called when the Web worker returns a speech recognition hypothesis.
  #
  # @param {W3hear.SpeechRecognitionList} results
  # @return undefined
  _onWorkerResult: (results) ->
    if @_started is false
      if @_wantFinalResult and results.length > 0 and results[0].isFinal
        @_wantFinalResult = false
      else
        return
    if @onresult isnt null
      @onresult new W3hear.SpeechRecognitionEvent(results, @)
    return

  # @property {function(W3hear.ResultEvent)} called when speech recognition
  #   results are available
  onresult: null

  # @property {function(Error)} called when speech recognition is not available
  #   due to a fatal error; the most likely cause is that the user denied
  #   Microphone access
  onerror: null

  # @property {Boolean} copied over from webkitSpeechRecognition; currently
  #   unused
  continuous: false

  # @property {Boolean} copied over from webkitSpeechRecognition; currently
  #   unused
  interimResults: false

  # @property {String} copied over from webkitSpeechRecognition; currently
  #   unused
  lang: null

# Namespace for implementation-internal classes.
W3hear._ = {}
