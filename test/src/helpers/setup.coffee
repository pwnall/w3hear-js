if global? and require? and module? and (not cordova?)
  # node.js
  # require('source-map-support').install()

  exports = global

  exports.chai = require 'chai'
  exports.sinon = require 'sinon'
  exports.sinonChai = require 'sinon-chai'


# Shared setup.
exports.assert = exports.chai.assert
exports.expect = exports.chai.expect
