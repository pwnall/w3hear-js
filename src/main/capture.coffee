# Captures sound from the user's microphone.
class W3hear._.Capture
  # Creates the sound capture object.
  #
  # This should be instantiated exactly once.
  #
  # @param {Object} options capture parameters
  # @option options {Number} inputBufferSize power of two to be used as the
  #   buffer size for the audio processor node
  constructor: (options) ->
    options ||= {}
    @_bufferSize = options.inputBufferSize or null
    @_started = false
    @_stream = null
    @_source = null
    @_context = W3hear._.Capture.audioContext()
    @_rate = @_context.sampleRate
    # HACK(pwnall): we should be using 0 output channels, but we can't, because
    #     of implementation bugs; Firefox handles this correctly, but Chrome
    #     doesn't issue audioprocess events, and the node.js polyfill throws an
    #     exception; it'd be easy to try/catch around the polyfill issue, but
    #     we have no solution for Chrome
    # TODO(pwnall): look into whether we need to fall back to
    #      createJavaScriptNode
    #      https://developer.mozilla.org/en-US/docs/Web/API/AudioContext.createJavaScriptNode
    @_node = @_context.createScriptProcessor @_bufferSize, 2, 2
    @_node.onaudioprocess = @_onAudioProcess.bind @
    @_node.connect @_context.destination

  # Starts capturing audio.
  #
  # If the capture was already started, this call is ignored.
  #
  # @param {MediaStream} the stream we're capturing from
  # @return undefined
  start: (stream) ->
    return if @_started is true
    @_started = true
    if @_stream is null
      @_stream = stream
      @_source = @_context.createMediaStreamSource @_stream
      @_source.connect @_node
    return

  # Stops capturing audio.
  #
  # If the capture wasn't started, this call is ignored.
  #
  # @return undefined
  stop: ->
    return if @_started is false
    @_started = false
    if @_source isnt null
      @_source.disconnect()
      @_source = null
      @_stream = null
    return

  # Removes all the resources associated with this capture object.
  #
  # After this method is called, the capture is stopped and cannot be resumed.
  #
  # This is mostly intended for testing. Applications that use the W3hear
  # object will always have exactly one capture object.
  #
  # @return undefined
  release: ->
    @stop()
    @_node.disconnect()
    @_node = null
    @_context = null
    return

  # Called when audio samples are available.
  #
  # @param [Array<Float32Array>] samples one typed array for each channel
  # @return ignored
  onSamples: (samples) ->
    return

  # The number of samples per second captured for each channel.
  #
  # @return {Number} number of samples per second captured
  sampleRate: ->
    @_rate

  # Called when audio data is available for processing.
  _onAudioProcess: (event) ->
    return if @_started is false
    samples = [event.inputBuffer.getChannelData(0),
               event.inputBuffer.getChannelData(1)]
    @onSamples samples
    return

  # Creates a Web Audio API context for the given options.
  #
  # @param {Object} options capture parameters passed to the {W3hear._.Capture}
  #   constructor
  # @return {AudioContext{ a Web Audio API context that follows the given
  #   options
  @audioContext: (options) ->
    @_context ||= new W3hear._.AudioContext()

  # The shared AudioContext used by all instances of this class.
  #
  # This can be set to an existing context by applications that use the Web
  # Audio API elsewhere.
  @_context: null
