# Event dispatch following a publisher-subscriber (PubSub) model.
class W3hear._.EventSource
  # Sets up an event source (publisher).
  constructor: () ->
    @_listeners = []

  # Registers a listener (subscriber) to events coming from this source.
  #
  # This is a simplified version of the addEventListener DOM API. Listeners
  # must be functions, and they can be removed by calling removeListener.
  #
  # This method is idempotent, so a function will not be added to the list of
  # listeners if was previously added.
  #
  # @param {function(Object)} listener called every time an event is fired
  # @return undefined
  addListener: (listener) ->
    unless typeof listener is 'function'
      throw new TypeError 'Invalid listener type; expected function'
    unless listener in @_listeners
      @_listeners.push listener
    return

  # Un-registers a listener (subscriber) previously added by addListener.
  #
  # This is a simplified version of the removeEventListener DOM API. The
  # listener must be exactly the same object supplied to addListener.
  #
  # This method is idempotent, so it will fail silently if the given listener
  # is not registered as a subscriber.
  #
  # @param {function(Object)} listener function that was previously passed in
  #   an addListener call
  # @return undefined
  removeListener: (listener) ->
    index = @_listeners.indexOf listener
    @_listeners.splice index, 1 if index isnt -1
    return

  # Informs the listeners (subscribers) that an event occurred.
  #
  # Event sources configured for non-cancelable events call all listeners in an
  # unspecified order. Sources configured for cancelable events stop calling
  # listeners as soon as one listener returns false value.
  #
  # @param {Object} event passed to all the registered listeners
  # @return undefined
  dispatch: (event) ->
    for listener in @_listeners
      listener event
    return
