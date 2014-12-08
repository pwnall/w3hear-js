# Loads a Web worker and implements the communcation protocol with it.
class W3hear._.WorkerProxy
  # Creates a new proxy for a Web worker running a speech recognition engine.
  #
  # @param {Object} system host system configuration details
  # @option system {Number} sampleRate the sampling rate of the Web Audio
  #   context used to process microphone information
  # @param {Object} options configuration for the worker
  # @option options {String} workerPath the directory that contains the worker
  #   script; this must also contain the compiled speech engines and data files
  # @option options {String} workerFile the name of the worker file; the
  #   default is 'w3hear_worker.js'
  # @option options {String} engine the name of the desired speech engine; the
  #   default is 'sphinx'
  # @option options {String} modelData the name of the data file for the speech
  #   engine's model; the default is 'en'
  # @option options {Boolean} engineDebug if true, the engine's output is sent
  #   to the console; debug output is disabled by default
  # @option options {Number} modelRate the sample rate used the data files; by
  #   default, the engine is instructed to choose its (default) rate
  constructor: (system, options) ->
    @onReady = new W3hear._.EventSource()
    @_rate = system.sampleRate
    options ||= {}
    @_engine = options.engine or 'sphinx'
    @_debug = !!options.engineDebug
    @_model = options.modelData or 'en'
    @_modelRate = options.modelRate or null
    # TODO(pwnall): consider using the directory part of window.location as a
    #               default, when available
    @_path = options.workerPath
    unless @_path.substring(@_path.length - 1) is '/'
      @_path += '/'
    @_worker = null

    workerFile = options.workerFile || 'w3hear_worker.js'
    @_startWorker workerFile

  # Sends sound data to the Web worker.
  #
  # @param {Array<Float32Array>} samples a typed array for each sound channel;
  #   this method will neuter the typed arrays
  # @return undefined
  sendSamples: (samples) ->
    # NOTE: we can't transfer the sample buffers because Chrome reuses the
    #       buffers; this probably makes sense for every implementation
    @_worker.postMessage { type: 'sound', samples: samples }
    return

  # Asks the Web worker to produce a speech recognition hypothesis.
  #
  # The worker produces hypothesis periodically. This is called when the API
  # user specifically ends the speech recognition process and asks for a final
  # hypothesis
  #
  # @return undefined
  requestResult: ->
    @_worker.postMessage { type: 'stop' }
    return

  # Called when the Web worker produces a speech recognition hypothesis.
  #
  # @param {W3hear.SpeechRecognitionResultList} results the hypothesis produced
  #   by the worker
  # @return ignored
  onResult: (results) ->
    return

  # Called when the speech recognition engine logs a message.
  #
  # This methd is only called when engine debugging is enabled.
  #
  # The method is public so applications can override it if they wish to
  # implement custom logging, such as uploading error logs to an analytics
  # server.
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

  # Forcibly terminates this proxy's Web worker.
  #
  # This method is intended to facilitate testing. Terminating the Web worker
  # may leave the W3hear recognizer that depends on the worker in an undefined
  # state.
  #
  # @return undefined
  terminate: ->
    if @_worker isnt null
      @_worker.terminate()
      @_worker = null
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
      when 'result'
        @onResult new W3hear.SpeechRecognitionResultList(data)
    return

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
        debug: @_debug, rate: @_rate, modelRate: @_modelRate)
    return

  # @property {W3hear._.EventSource} fires an event when the speech recognition
  #   engine finishes booting and can start processing sound
  onReady: null

  # @property {Boolean} true when the speech engine boots and can take commands
  ready: null
