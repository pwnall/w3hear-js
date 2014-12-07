# Common functionality for speech recognition engines.
class W3hearWorker.Driver
  # Creates a driver for an instance of the engine.
  #
  # @param {Object} module the Module object in the Emscripten system
  # @param {Object} options engine setup options
  constructor: (module, options) ->
    @_module = module
    @_started = false
    @_lastResult = null

  # Feeds sound samples to the speech recognition engine.
  #
  # Subclasses should override the protected {#_process} method, which is
  # guaranteed to be called when the engine is in a started state.
  #
  # @param {Array<ArrayBuffer>} samples one array for each sound channel;
  #   stereo sound will have two channels
  # @return undefined
  process: (samples) ->
    if @_started is false
      @_start()
      @_started = true
    @_process samples
    return

  # Completes a speech recognition operation and flushes the engine's state.
  #
  # Subclasses should override the private {#_stop} method, which is guaranteed
  # to be called when the engine is in a started state.
  #
  # @return undefined
  stop: ->
    return if @_started is false
    @_stop()
    @_started = false
    @_lastResult = null
    return

  # Returns the recognition engine's hypothesis for the data it received.
  #
  # @param {Boolean} nullIfStale if true, the method will return null when the
  #   engine's hypothesis matches the last returned hypothesis
  # @return {Object} the recognition engine's hypothesis
  result: (nullIfStale) ->
    newResult = @_result()
    if nullIfStale and @_equalsLastResult(newResult)
      return null
    @_lastResult = newResult
    @_lastResult.final = !@_started
    @_lastResult

  # Compares the current result with {#_lastResult}.
  #
  # @private
  # This is used by the implementation of {#result}. Subclasses should not need
  # to call it.
  #
  # @param {Object} newResult the result to be compared
  # @return {Boolean} true if the given result is equivalent to {#_lastResult}
  _equalsLastResult: (newResult) ->
    return false if @_lastResult is null
    newResult.text is @_lastResult.text and newResult.conf is @_lastResult.conf

  # Computes the path to a model data file.
  #
  # Drivers must implement this constructor method.
  #
  # @param {String} model the model's name, e.g. "en"
  # @return {String} the path to the file that contains the Emscripten-packaged
  #   model data, relative to the worker script's directory
  @modelDataFile: (model) ->
    throw new Error 'modelDataFile not implemented in Driver subclass'

  # Drivers must implement this constructor property.
  #
  # @property {String} the path to the file that contains the Emscripten
  #   compilation result, relative to the worker script's directory
  @engineFile: null

  # Subclasses should override this to start the recognition engine.
  #
  # @protected
  # This is guaranteed to be called when the speech recognition process is
  # stopped.
  #
  # @return undefined
  _start: ->
    return

  # Subclasses should override this to start the recognition engine.
  #
  # @protected
  # This is guaranteed to be called when the speech recognition process is
  # started.
  #
  # @return undefined
  _stop: ->
    return

  # Subclasses should override this to feed sound samples to the engine.
  #
  # @protected
  # This is guaranteeed to be called when the speech recognition process is
  # started.
  #
  # @param {Array<ArrayBuffer>} samples one array for each sound channel;
  #   stereo sound will have two channels
  # @return undefined
  _process: (samples) ->
    throw new Error '_process not implemented in Driver subclass'

  # Subclasses should override this to translate the engine's hypothesis.
  #
  # @protected
  # This should return the engine's current hypothesis or hypotheses, without
  # worrying about stale results.
  #
  # @return {Object} the engine's current hypothesis / hypotheses
  _result: ->
    throw new Error '_result not implemented in Driver subclass'
