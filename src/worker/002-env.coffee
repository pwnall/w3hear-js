# Helpers for interacting with the JavaScript environment we run in.

if typeof self isnt 'undefined' and typeof self.importScripts is 'function' and
    typeof self.postMessage is 'function'
  # Running inside a Web Worker. This could still be under node.js, if a
  # Web Worker polyfill is used.
  W3hearWorkerGlobal = self
  W3hearWorkerRequire = null
  W3hearWorkerImportScripts = self.importScripts.bind self
  W3hearWorkerGlobal.W3hearWorker = W3hearWorker

else if typeof global isnt 'undefined' and typeof module isnt 'undefined' and
    'exports' of module
  # Running inside node.js, but not in a Web Worker environment.
  # This configuration is supported for the purpose of running tests.
  W3hearWorkerGlobal = global
  W3hearWorkerRequire = require
  W3hearWorkerImportScripts = null
  module.exports = W3hearWorker

else if typeof window isnt 'undefined' and typeof navigator isnt 'undefined'
  # Running inside a browser.
  throw new Error 'w3hear_worker.js should be run in a Web worker'

else
  throw new Error(
      'w3hear_worker.js loaded in an unsupported JavaScript environment.')

# The global environment object.
W3hearWorker.global = W3hearWorkerGlobal
W3hearWorker.require = W3hearWorkerRequire
W3hearWorker.importScripts = W3hearWorkerImportScripts
