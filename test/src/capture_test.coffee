Capture = W3hear._.Capture

describe 'Capture', ->
  beforeEach ->
    @capture = new Capture inputBufferSize: 4096

  describe 'with a MediaStream', ->
    beforeEach ->
      # NOTE: the node.js polyfill doesn't implement MediaStream integration,
      #       so we use a stubbing hack there
      # NOTE 2: the MediaStream implementation is unstable in Chrome, which
      #         makes this test unreliable
      @useMediaStream = !!(
          W3hear._.AudioContext.prototype.createMediaStreamSource &&
          W3hear._.AudioContext.prototype.createMediaStreamDestination &&
          W3hear._.global.navigator &&
          /firefox/i.test('' + W3hear._.global.navigator.userAgent))

      @left = new Array 12288
      @right = new Array 12288
      for i in [0...12288]
        # Sample data that does not repeat by a power of two and consists
        # solely of 1, 0 and -1, so no floating point oddness happens.
        @left[i] = 1 - (Math.floor(i / 7) % 3)
        @right[i] = 1 - (Math.floor((i + 1) / 7) % 3)

      if @useMediaStream
        @context = new W3hear._.AudioContext()
      else
        @context = @capture._context

      @buffer = @context.createBuffer 2, @left.length, 44100
      leftData = @buffer.getChannelData 0
      rightData = @buffer.getChannelData 1
      for i in [0...@left.length]
        leftData[i] = @left[i]
        rightData[i] = @right[i]
      @source = @context.createBufferSource()
      @source.buffer = @buffer
      @source.loop = false
      if @useMediaStream
        @destination = @context.createMediaStreamDestination()
        @source.connect @destination
        @stream = @destination.stream
      else
        @destination = null
        @stream = { _source: @source }
        @context.createMediaStreamSource = (stream) =>
          expect(stream).to.equal @stream
          expect(stream._source).to.equal @source
          return stream._source

    afterEach ->
      # NOTE: this makes sure the capture stops, even if the test fails
      @capture.stop()
      @source.stop()
      if @destination
        @source.disconnect()

    it 'calls onSample correctly', (done) ->
      # NOTE: we use the fact that the first sample is non-zero to sync
      expect(@left[0]).not.to.equal 0

      left = []
      right = []
      @capture.onSamples = (samples) =>
        expect(samples.length).to.equal 2
        expect(samples[0].length).to.equal samples[1].length
        for i in [0...samples[0].length]
          # HACK(pwnall): synchronizing in the stream
          continue if left.length is 0 and samples[0][i] != @left[0]
          break if left.length is @left.length

          left.push samples[0][i]
          right.push samples[1][i]
        return unless left.length >= @left.length

        for i in [0..@left.length]
          unless right[i] is @right[i]
            expect(i + " right: " + right[i]).to.
                equal(i + " right: " + @right[i])
          unless left[i] is @left[i]
            expect(i + " left: " + left[i]).to.equal(i + " left: " + @left[i])
        @capture.stop()
        @source.stop()
        done()
      @capture.start @stream
      @source.start @context.currentTime, 0
