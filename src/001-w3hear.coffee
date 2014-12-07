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
    @_proxy = new W3hear._.WorkerProxy options
    @_proxy.onResult = @_onWorkerResult.bind(@)
    @_capture = new W3hear._.Capture options
    # NOTE: the Capture object only generates samples when started, so we don't
    #       need to worry about posting useless messages to the Web Worker
    @_capture.onSamples = @_proxy.sendSamples.bind(@)
    @_started = false
    @_oneLastResult = false

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
    @_capture.stop()
    return

  # Called when the Web worker returns a speech recognition hypothesis.
  #
  # @param {W3hear.SpeechRecognitionList} results
  # @return undefined
  _onResult: (results) ->
    if @_started is false
      if @_oneLastResult
        @_oneLastResult = false
      else
        return
    return if @onresult is null
    @onresult new W3hear.SpeechRecognitionEvent(results, @)
    return

  # @property {function(W3hear.ResultEvent)} called when speech recognition
  #   results are available
  onresult: null

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
