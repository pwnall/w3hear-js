window.addEventListener 'load', ->
  transcriptElement = document.querySelector '#transcript'
  window.recognizer = new W3hear(
      engine: 'sphinx', engineDebug: true, modelData: 'en',
      workerPath: window.location.origin + '/lib',
      workerFile: 'w3hear_worker.min.js')
  recognizer.onresult = (event) ->
    console.log event
    transcriptElement.value = event.results[0][0].transcript

  document.querySelector('#start').addEventListener 'click', ->
    recognizer.start()
  document.querySelector('#stop').addEventListener 'click', ->
    recognizer.stop()
