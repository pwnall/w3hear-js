glob = require 'glob'
open = require 'open'

run = require './run.coffee'

nodetest = (callback) ->
  reporter = if process.env['LIST'] then 'spec' else 'dot'

  test_cases = glob.sync 'test/js/**/*_test.js'
  test_cases.sort()  # Consistent test case order.
  run 'node node_modules/mocha/bin/mocha --colors --slow 200 ' +
      "--timeout 5000 --reporter #{reporter} --globals W3gram " +
      '--require test/js/helpers/setup.js ' + test_cases.join(' '),
      noExit: true, (code) ->
        callback(code) if callback

webtest = (callback) ->
  TestServers = require '../test/js/helpers/test_servers.js'
  testServers = new TestServers()
  testServers.listen ->
    url = testServers.testUrl()
    if 'BROWSER' of process.env
      if process.env['BROWSER'] is 'false'
        console.log "Please open the URL below in your browser:\n    #{url}"
        callback() if callback?
      else
        open url, process.env['BROWSER'], ->
          callback() if callback?
    else
      open url, ->
        callback() if callback?

module.exports.node = nodetest
module.exports.web = webtest
