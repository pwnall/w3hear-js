# The driver for the CMU Sphinx speech recognition engine.
class W3hearWorker.SphinxDriver extends W3hearWorker.Driver
  # Creates a driver for an instance of the engine.
  #
  # @param {Object} module the Module object in the Emscripten system
  # @param {Object} options engine setup options
  # @option option {String} model the name of the file containing data for the
  #   engine's models
  constructor: (module, options) ->
    super module, options
    @_config = null
    @_recognizer = null
    @_buffer = null
    @_outIndex = 0
    @_outAccum = 0
    @_outCount = 0

    @_inRate = options.rate
    @_outRate = options.modelRate or 16000

    @_buildConfig options
    @_buildRecognizer()
    @_resetResampler()

  # Builds the Config object for pocketsphinx.
  #
  # @private
  # This is called by the constructor.
  #
  # @param {Object} options module setup options
  # @option option {String} model the name of the file containing data for the
  #   engine's models
  # @return undefined
  _buildConfig: (options) ->
    @_config = new @_module.Config
    @_config.push_back ['-hmm', options.model]
    @_config.push_back ['-dict', "#{options.model}.dic"]
    @_config.push_back ['-lm', "#{options.model}.DMP"]
    return

  # Builds the global Recognizer object for pocketsphinx.
  #
  # @private
  # This is called by the constructor.
  #
  # @return undefined
  _buildRecognizer: ->
    @_recognizer = new @_module.Recognizer @_config
    return

  # @see {W3hearWorker.Driver#_start}
  _start: ->
    status = @_recognizer.start()
    if status isnt @_module.ReturnType.SUCCESS
      @_module['PrintErr']('Recognizer.start() returned non-success status')

  # @see {W3hearWorker.Driver#_stop}
  _stop: ->
    @_resetResampler()
    status = @_recognizer.stop()
    if status isnt @_module.ReturnType.SUCCESS
      @_module['PrintErr']('Recognizer.stop() returned non-success status')

  # @see {W3hearWorker.Driver#_process}
  _process: (samples) ->
    @_resample samples

    status = @_recognizer.process @_buffer
    if status isnt @_module.ReturnType.SUCCESS
      @_module['PrintErr']('Recognizer.process() returned non-success status')

  # @see {W3hearWorker.Driver#_result}
  _result: ->
    text = @_recognizer.getHyp()
    { text: text, conf: 0 }

  # Cleans the resampler state.
  #
  # @return undefined
  _resetResampler: ->
    if @_buffer isnt null
      @_buffer.delete()
      @_buffer = null
    @_buffer = new @_module.AudioBuffer()
    @_outIndex = 0
    @_outAccum = 0
    @_outCount = 0
    return

  # Handles resampling and conversion from Float32Array to Int16Array.
  #
  # @param {Array<Float32Array>} samples the sound data to be resampled
  # @return undefined
  _resample: (samples) ->
    bufferSize = @_buffer.size()
    usePush = bufferSize is 0
    j = 0

    # outIndex is the fractional part of the position in the output buffer,
    # multiplied by the input sample rate.
    #
    # Whenever we process an input sample, outIndex jumps by the output sample
    # rate. When outIndex exceeds the input sample rate, we're ready to output
    # a sample and reduce outIndex by the input rate. (modular reduction)
    for i in [0...samples[0].length]
      sample = samples[0][i] + samples[1][i]
      @_outAccum += sample
      @_outCount += 1
      @_outIndex += @_outRate
      if @_outIndex >= @_inRate
        @_outIndex -= @_inRate
        value = (@_outAccum / @_outCount) * 16383
        if @_outIndex is 0
          @_outAccum = 0
          @_outCount = 0
        else
          @_outAccum = sample
          @_outCount = 1
        if usePush
          @_buffer.push_back value
        else
          @_buffer.set j, value
          j += 1
          if j is bufferSize
            usePush = true

    if usePush is false and j < bufferSize
      @_buffer.resize j
    return

  # @see {W3hearWorker.Driver#modelDataFile}
  @modelDataFile: (model) ->
    "sphinx/models/#{model}.js"

  # @see {W3hearWorker.Driver#engineFile}
  @engineFile: 'sphinx/pocketsphinx.js'
