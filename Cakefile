async = require 'async'
fs = require 'fs-extra'
glob = require 'glob'
path = require 'path'
watch = require 'watch'

require 'coffee-script/register'
build = require './tasks/build'
clean = require './tasks/clean'
run = require './tasks/run'
test = require './tasks/test'
vendor = require './tasks/vendor'

task 'build', ->
  clean ->
    build ->
      build.package()

task 'clean', ->
  clean()

task 'watch', ->
  setupWatch()

task 'test', ->
  build ->
    test.node (code) ->
      process.exit code

task 'webtest', ->
  build ->
    vendor ->
      test.web()

task 'vendor', ->
  fs.removeSync 'test/vendor' if fs.existsSync 'test/vendor'
  vendor()

task 'tokens', ->
  fs.removeSync 'test/token' if fs.existsSync 'test/token'
  build ->
    ssl_cert ->
      tokens ->
        process.exit 0

task 'doc', ->
  fs.mkdirSync 'doc' unless fs.existsSync 'doc'
  run 'node_modules/codo/bin/codo'

task 'devdoc', ->
  fs.mkdirSync 'doc' unless fs.existsSync 'doc'
  run 'node_modules/codo/bin/codo --private'

setupWatch = (callback) ->
  scheduled = true
  buildNeeded = true
  cleanNeeded = true
  onTick = ->
    scheduled = false
    if cleanNeeded
      buildNeeded = false
      cleanNeeded = false
      console.log "Doing a clean build"
      clean -> build -> test.node()
    else if buildNeeded
      buildNeed = false
      console.log "Building"
      build -> test.node()
  process.nextTick onTick

  watchMonitor = (monitor) ->
    monitor.on 'created', (fileName) ->
      return unless path.basename(fileName)[0] is '.'
      buildNeeded = true
      unless scheduled
        scheduled = true
        process.nextTick onTick
    monitor.on 'changed', (fileName) ->
      return unless path.basename(fileName)[0] is '.'
      buildNeeded = true
      unless scheduled
        scheduled = true
        process.nextTick onTick
    monitor.on 'removed', (fileName) ->
      return unless path.basename(fileName)[0] is '.'
      cleanNeeded = true
      buildNeeded = true
      unless scheduled
        scheduled = true
        process.nextTick onTick

  watch.createMonitor 'src/', watchMonitor
  watch.createMonitor 'test/src/', watchMonitor

