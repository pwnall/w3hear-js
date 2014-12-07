# The driver for the CMU Sphinx speech recognition engine.
class W3hearWorker.SphinxDriver
  # Creates a driver for an instance of the engine.
  #
  # @param {Object} module the Module object in the Emscripten system
  # @param {Object} options engine setup options
  # @option option {String} model the name of the file containing data for the
  #   engine's models
  constructor: (module, options) ->
    @_module = module
    @_config = null
    @_recognizer = null
    @_buildConfig options
    @_buildRecognizer()

  # Builds the Config object for pocketsphinx.
  #
  # @param {Object} options module setup options
  # @option option {String} model the name of the file containing data for the
  #   engine's models
  _buildConfig: (options) ->
    @_config = new @_module.Config
    @_config.push_back ['hmm', "models/#{options.model}"]
    @_config.push_back ['dict', "models/#{options.model}.dic"]
    @_config.push_back ['lm', "models/#{options.model}.DMP"]
    return

  # Builds the global Recognizer object for pocketsphinx.
  _buildRecognizer: ->
    @_recognizer = new @_module.Recognizer @_config

  # Computes the path to a model data file.
  #
  # @param {String} model the model's name, e.g. "en"
  # @return {String} the path to the file that contains the Emscripten-packaged
  #   model data, relative to the worker script's directory
  @modelDataFile: (model) ->
    "sphinx/models/#{model}.js"

  # @property {String} the path to the file that contains the Emscripten
  #   compilation result, relative to the worker script's directory
  @engineFile: 'sphinx/pocketsphinx.js'
