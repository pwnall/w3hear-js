fs = require 'fs'
path = require 'path'

run = require './run.coffee'

download = ([url, file], callback) ->
  if fs.existsSync file
    callback() if callback?
    return

  run "curl -o #{file} #{url}", callback

module.exports = download
