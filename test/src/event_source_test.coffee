EventSource = W3hear._.EventSource

describe 'EventSource', ->
  beforeEach ->
    @source = new EventSource()

    # 3 listeners, 1 and 2 are already hooked up
    @event1 = null
    @listener1 = (event) =>
      @event1 = event
      return
    @source.addListener @listener1
    @event2 = null
    @listener2 = (event) =>
      @event2 = event
      return
    @source.addListener @listener2
    @event3 = null
    @listener3 = (event) =>
      @event3 = event
      return

  describe '#addListener', ->
    it 'adds a new listener', ->
      @source.addListener @listener3
      expect(@source._listeners).to.deep.
          equal [@listener1, @listener2, @listener3]

    it 'does not add an existing listener', ->
      @source.addListener @listener2
      expect(@source._listeners).to.deep.equal [@listener1, @listener2]

    it 'is idempotent', ->
      @source.addListener @listener3
      @source.addListener @listener3
      expect(@source._listeners).to.deep.
          equal [@listener1, @listener2, @listener3]

    it 'refuses to add non-functions', ->
      expect(=> @source.addListener(42)).to.throw(TypeError, /listener type/)

  describe '#removeListener', ->
    it 'does nothing for a non-existing listener', ->
      @source.removeListener @listener3
      expect(@source._listeners).to.deep.equal [@listener1, @listener2]

    it 'removes a listener at the end of the queue', ->
      @source.removeListener @listener2
      expect(@source._listeners).to.deep.equal [@listener1]

    it 'removes a listener at the beginning of the queue', ->
      @source.removeListener @listener1
      expect(@source._listeners).to.deep.equal [@listener2]

    it 'removes a listener at the middle of the queue', ->
      @source.addListener @listener3
      @source.removeListener @listener2
      expect(@source._listeners).to.deep.equal [@listener1, @listener3]

    it 'removes all the listeners', ->
      @source.removeListener @listener1
      @source.removeListener @listener2
      expect(@source._listeners).to.deep.equal []

  describe '#dispatch', ->
    beforeEach ->
      @event = { answer: 42 }

    it 'passes event to registered listeners', ->
      @source.dispatch @event
      expect(@event1).to.equal @event
      expect(@event2).to.equal @event
      expect(@event3).to.equal null

    describe 'after adding a new listener', ->
      beforeEach ->
        @source.addListener @listener3

      it 'calls all the listeners', ->
        @source.dispatch @event
        expect(@event1).to.equal @event
        expect(@event2).to.equal @event
        expect(@event3).to.equal @event
