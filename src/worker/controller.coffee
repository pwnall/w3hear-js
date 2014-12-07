# Interprets commands received from the worker's master and responds.
#
# This should be a singleton.
class W3hearWorker.ControllerClass
  # Creates a controller.
  constructor: ->
    @_loader = null
    @_path = null
    @_engine = null
    @_wired = false
    @_wireListener()

  # Called when the speech recognition engine wants to log an error message.
  #
  # @param {String} message the message to be logged
  # @return undefined
  onPrintError: (message) ->
    @_postMessage type: 'dlog', level: 'error', message: message
    return

  # Called when the speech recognition engine wants to log a message.
  #
  # @return undefined
  onPrint: (message) ->
    @_postMessage type: 'dlog', level: 'info', message: message
    return

  # Boots the worker.
  #
  # @param {Object} the message received from the master that contains
  #   initialization settings, such as the speech engine and model data to be
  #   loaded into this worker
  # @return undefined
  _boot: (data) ->
    if @_loader isnt null
      throw new Error("The worker has already booted")

    @_path = data.path
    @_loader = new W3hearWorker.Loader @_path, @
    @_engine = @_loader.loadEngine data
    @_postMessage type: 'ready'
    return

  # Called when the master sent sound samples for processing.
  #
  # @param {Object} the message received from the master that contains the
  #   sound samples
  # @return undefined
  _onSamples: (data) ->
    return if @_engine is null
    @_engine.process data.samples
    result = @_engine.result true
    unless result is null
      @_postMessage type: 'result', result: result
    return

  # Called when the master asked that the recognition be stopped.
  #
  # @return undefined
  _onStopRequest: ->
    @_engine.stop()
    result = @_engine.result false
    @_postMessage type: 'result', result: result
    return

  # Sets up the controller's listener to receive the worker's messages.
  #
  # @return undefined
  _wireListener: ->
    return if @_wired is true
    if W3hearWorker.global.addEventListener and W3hearWorker.global.postMessage
      W3hearWorker.global.onmessage = @_onMessage.bind(@)
      @_wired = true
    return

  # Called when the worker receives a message.
  #
  # @param {MessageEvent} event contains the received message
  # @return undefined
  _onMessage: (event) ->
    data = event.data
    switch data.type
      when 'boot'
        @_boot data
      when 'sound'
        @_onSamples data
      when 'stop'
        @_onStopRequest()
        null
    return

  # Sends a message to the worker's master.
  #
  # @param {Object} data the message, which will be subjected to the structured
  #   cloning algorithm
  # @param {Object} transferables sequence of typed arrays that will be
  #   neutered when sending them to the master
  _postMessage: (data, transferables) ->
    W3hearWorker.global.postMessage data, transferables

W3hearWorker.Controller = new W3hearWorker.ControllerClass()
