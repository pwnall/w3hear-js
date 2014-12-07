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
    @_buildConfig options
    @_buildRecognizer()

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
    status = @_recognizer.stop()
    if status isnt @_module.ReturnType.SUCCESS
      @_module['PrintErr']('Recognizer.stop() returned non-success status')

  # @see {W3hearWorker.Driver#_process}
  _process: (samples) ->
    if @_buffer isnt null
      # Reuse existing buffer if possible, to reduce GC pressure.
      if samples[0].length is @_buffer.size()
        for i in [0...samples[0].length]
          @_buffer.set i, (samples[0][i] + samples[1][i]) * 16383
      else
        @_buffer.delete()
        @_buffer = null

    if @_buffer is null
      # Could not reuse an existing buffer, must create a new one.
      @_buffer = new @_module.AudioBuffer()
      for i in [0...samples[0].length]
        @_buffer.push_back (samples[0][i] + samples[1][i]) * 16383

    status = @_recognizer.process @_buffer
    if status isnt @_module.ReturnType.SUCCESS
      @_module['PrintErr']('Recognizer.process() returned non-success status')

  # @see {W3hearWorker.Driver#_result}
  _result: ->
    text = @_recognizer.getHyp()
    { text: text, conf: 0 }

  # @see {W3hearWorker.Driver#modelDataFile}
  @modelDataFile: (model) ->
    "sphinx/models/#{model}.js"

  # @see {W3hearWorker.Driver#engineFile}
  @engineFile: 'sphinx/pocketsphinx.js'
