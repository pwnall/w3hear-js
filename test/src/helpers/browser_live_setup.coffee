window.addEventListener 'load', ->
  transcriptElement = document.querySelector '#transcript'
  startButton = document.querySelector '#start'
  stopButton = document.querySelector '#stop'

  window.recognizer = new W3hear(
      engine: 'sphinx', engineDebug: true, modelData: 'en',
      workerPath: window.location.origin + '/lib',
      workerFile: 'w3hear_worker.min.js')
  recognizer.onresult = (event) ->
    transcriptElement.value = event.results[0][0].transcript
  recognizer._proxy.onReady.addListener ->
    startButton.disabled = false
    stopButton.disabled = false

  startButton.addEventListener 'click', ->
    recognizer.start()
  stopButton.addEventListener 'click', ->
    recognizer.stop()
