# Helpers for interacting with the JavaScript environment we run in.

if typeof global isnt 'undefined' and typeof module isnt 'undefined' and
    'exports' of module
  # Running inside node.js.
  W3hearGlobal = global
  module.exports = W3hear

  # Polyfills for Web APIs.
  W3hear._.AudioContext = require('web-audio-api').AudioContext

  # TODO(pwnall): restore the node.js Worker tests if the polyfill becomes more
  #               stable
  W3hear._.Worker = null  # require('webworker-threads').Worker

  # No node.js polyfill for navigator.getUserMedia. This is useless without a
  # Web Worker polyfill anyway.
  W3hear._.getUserMedia = null

else if typeof window isnt 'undefined' and typeof navigator isnt 'undefined'
  # Running inside a browser.
  W3hearGlobal = window
  window.W3hear = W3hear

  # Web APIs.
  W3hear._.AudioContext = window.AudioContext || window.webkitAudioContext
  W3hear._.Worker = window.Worker
  W3hear._.getUserMedia = (navigator.getUserMedia ||
      navigator.webkitGetUserMedia || navigator.mozGetUserMedia).
      bind(navigator)

else
  throw new Error 'w3hear.js loaded in an unsupported JavaScript environment.'

# The global environment object.
W3hear._.global = W3hearGlobal
