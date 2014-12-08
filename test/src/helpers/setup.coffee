if global? and require? and module? and (not cordova?)
  # node.js
  # require('source-map-support').install()

  exports = global

  exports.W3hear = require '../../../lib/w3hear'
  exports.W3hearWorker = require '../../../lib/w3hear_worker'
  exports.chai = require 'chai'
  exports.sinon = require 'sinon'
  exports.sinonChai = require 'sinon-chai'

  controller = {
    onPrint: console.log
    onPrintError: console.error
  }
  exports.testSphinxLoader = new exports.W3hearWorker.Loader null, controller
  # NOTE: the resampling code is tested separately, so we set the input rate to
  #       match the engine's internal rate
  exports.testSphinxLoader.loadEngine(
      engine: 'sphinx', debug: false, model: 'digits', rate: 16000)
  exports.testXhrServer = ''

else
  # Browser tests.
  exports = window

  # We don't run the synchronous engine tests in the browser.
  exports.testSphinxLoader = null

  # TODO(pwnall): not all browsers suppot location.origin
  exports.testXhrServer = exports.location.origin

# Shared setup.
exports.assert = exports.chai.assert
exports.expect = exports.chai.expect
