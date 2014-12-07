# Loads a Web worker and implements the communcation protocol with it.
class W3hear._.WorkerProxy
  # Creates a new proxy for a Web worker running a speech recognition engine.
  #
  # @param {Object} options configuration for the worker
  # @option {String} workerPath the directory that contains the worker script;
  #   this must also contain the compiled speech engines and data files
  # @option {String} workerFile the name of the worker file; the default is
  #   'w3hear_worker.js'
  # @option {String} engine the name of the desired speech engine; the default
  #   is 'sphinx'
  # @option {String} modelData the name of the data file for the speech
  #   engine's model; the default is 'en'
  # @option {Boolean} engineDebug if true, the engine's output is sent to the
  #   console
  constructor: (options) ->
    @onReady = new W3hear._.EventSource()
    options ||= {}
    @_engine = options.engine or 'sphinx'
    @_debug = !!options.engineDebug
    @_model = options.modelData or 'en'
    @_path = options.workerPath
    unless @_path.substring(@_path.length - 1, 1) is '/'
      @_path += '/'
    @_worker = null

    workerFile = options.workerFile || 'w3hear_worker.js'
    @_startWorker workerFile

  # Forcibly terminates this proxy's Web worker.
  #
  # @return undefined
  terminate: ->
    if @_worker isnt null
      @_worker.terminate()
      @_worker = null
    return

  # Called when the speech recognition engine logs a message.
  #
  # This only happens when engine debugging is enabled.
  #
  # @param {String} level 'info' or 'error'
  # @param {String} message the message logged by the engine
  # @return undefined
  debugLog: (level, message) ->
    switch level
      when 'error'
        console.error message
      when 'info'
        console.info message
      else
        throw new Error("Invalid dlog level: #{level}")
    return

  # Called when a message is received from the worker.
  #
  # @param {MessageEvent} event contains the received message
  # @return undefined
  _onMessage: (event) ->
    data = event.data
    switch data.type
      when 'dlog'
        @debugLog data.level, data.message
      when 'ready'
        @ready = true
        @onReady.dispatch @

  # Creates the Worker and sends it the information that it needs to boot.
  #
  # @private
  # This is called by the {W3hear._.WorkerProxy} constructor automatically.
  #
  # @param {String} workerFile the name of the script containing the worker
  #   file
  # @return undefined
  _startWorker: (workerFile) ->
    workerUrl = @_path + workerFile
    @_worker = new W3hear._.Worker workerUrl
    @_worker.onmessage = @_onMessage.bind @
    @_worker.postMessage(
        type: 'boot', path: @_path, engine: @_engine, model: @_model,
        debug: @_debug)
    return

  # Sends a message to the worker.
  #
  # @private
  # This is called by the public API functions when necessary.
  #
  # @param {Object} data the message, which will be subjected to the structured
  #   cloning algorithm
  # @param {Object} transferables sequence of typed arrays that will be
  #   neutered when sending them to the worker
  _postMessage: (data, transferables) ->
    @_worker.postMessage data, transferables

  # @property {W3hear._.EventSource} fires an event when the speech recognition
  #   engine finishes booting and can start processing sound
  onReady: null

  # @property {Boolean} true when the speech engine boots and can take commands
  ready: null
