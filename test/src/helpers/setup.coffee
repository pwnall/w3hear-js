if global? and require? and module? and (not cordova?)
  # node.js
  # require('source-map-support').install()

  exports = global

  exports.W3hear = require '../../../lib/w3hear'
  exports.chai = require 'chai'
  exports.sinon = require 'sinon'
  exports.sinonChai = require 'sinon-chai'

else
  # Browser tests.
  exports = window

  # TODO(pwnall): not all browsers suppot location.origin
  exports.testXhrServer = exports.location.origin

# Shared setup.
exports.assert = exports.chai.assert
exports.expect = exports.chai.expect
