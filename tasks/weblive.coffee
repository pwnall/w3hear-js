glob = require 'glob'
open = require 'open'

run = require './run'

weblive = (callback) ->
  TestServers = require '../test/js/helpers/test_servers.js'
  testServers = new TestServers()
  testServers.listen ->
    url = testServers.liveUrl()
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

module.exports.web = weblive
