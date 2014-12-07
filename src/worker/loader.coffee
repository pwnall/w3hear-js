# Loads a speech recognition engine and its data files.
class W3hearWorker.Loader
  # Creates a new loader.
  #
  # @option {String} enginePath the directory that contains the worker script;
  #   this also contains the compiled speech engines and data files
  # @option {W3hearWorker.Controller} controller if speech engine debugging is
  #   enabled, receives onPrint and onPrintError notifications
  constructor: (workerPath, controller) ->
    @_path = workerPath
    @_controller = controller
    @_driver = null
    @_module = null

  # Loads a speech recognition engine and its driver.
  #
  # This must be called at most once for a loader.
  #
  # @param {Object} options the boot options
  # @return {W3hearWorker.EngineDriver} the driver for the loaded speech
  #   recognition engine
  loadEngine: (options) ->
    if @_driver isnt null
      throw new Error 'Speech recognition engine already loaded'

    @_prepareModule options if @_module is null
    driverClass = @_driverClass options.engine
    @_loadFiles [driverClass.engineFile,
                 driverClass.modelDataFile(options.model)]
    @_driver = new driverClass(@_module, options)
    @_driver

  # Loads an Emscripten file.
  #
  # @param {Array<String>} names the names of compiled Emscripten files,
  #   relative to the worker script's directory
  # @return undefined
  _loadFiles: (names) ->
    if W3hearWorker.importScripts is null
      # Running inside node.js
      fs = W3hearWorker.require 'fs'
      path = W3hearWorker.require 'path'
      js = []
      for name in names
        filePath = path.join __dirname, name
        js.push fs.readFileSync(filePath, encoding: 'utf8')
      Module = @_module
      eval js.join(";\n")
    else
      W3hearWorker.global.Module = @_module
      urls = (@_path + name for name in names)
      # NOTE: we're doing the apply trick so we can get the browser to start
      #       fetching both/all the files as quickly as possible
      W3hearWorker.global.importScripts.apply W3hearWorker.global, urls
    return

  # The constructor for an engine's driver.
  #
  # @param {String} name the engine's name
  # @return {function} the constructor for the given engine
  _driverClass: (name) ->
    switch name
      when 'sphinx'
        return W3hearWorker.SphinxDriver
      else
        throw new Error "Unknown speech recognition engine: #{name}"

  # Sets up the Module object.
  #
  # @param {Object} options the speech recognition engine initialization
  #   settings
  # @return undefined
  _prepareModule: (options) ->
    # http://kripken.github.io/emscripten-site/docs/api_reference/module.html
    @_module = {}

    if options.debug
      # TODO(pwnall): pass these to master page
      @_module.print = @_controller.onPrint.bind @_controller
      @_module.printErr = @_controller.onPrintError.bind @_controller
      @_module.logReadFiles = true
    else
      @_module.print = -> return
      @_module.printErr = -> return
      @_module.logReadFiles = false
    return

