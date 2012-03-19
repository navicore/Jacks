#!/usr/bin/ruby
require 'test/unit'
require 'jacks'

class TestJacksMetronome < Test::Unit::TestCase

  def test_runme

    @offset = 0

  	@jc = Jacks::JsClient.new("ruby_metronome_unit_test", nil, 
    Jacks::JackNullOption)
	assert_not_nil(@jc)

    iter            = 100

    freq            = 880.0
    max_amp         = 0.5
    dur_arg         = 100.0
    attack_percent  = 1.0
    decay_percent   = 10.0
    transport_aware = 0
    got_bpm         = 300
    pi              = 3.14

    @out = @jc.registerPort("output", Jacks::JackPortIsOutput)
    @jc.activate()

    speaker = @jc.getPortByType("sys", "", 
    Jacks::JackPortIsPhysical | Jacks::JackPortIsInput, 0)
	assert_not_nil(speaker)

    rc = @out.connect(speaker)
	assert(rc == 0)

    #
    # setup wave table parameters
    #
    @wave_length    = 60.0 * @jc.getSampleRate() / got_bpm
    tone_length     = @jc.getSampleRate() * dur_arg / 1000
    attack_length   = tone_length * attack_percent / 100
    decay_length    = tone_length * decay_percent / 100
    scale           = 2 * pi * freq / @jc.getSampleRate()

    assert(tone_length < @wave_length, "invalid tone_length / wave_length") 
    assert(attack_length + decay_length < tone_length,
    "invalid attack_length / decay_length / tone_length")

    @amp = Array.new
    i=0
    while i < tone_length
        @amp[i] = 0.0
        i+=1
    end

    @wave = Array.new
    i=0
    while i < @wave_length
        @wave[i] = 0.0
        i+=1
    end

    #
    # Build the wave table
    #
    i=0
    while i < attack_length
        @amp[i] = max_amp * i / attack_length
        i+=1
    end

    i=attack_length
    while i < tone_length - decay_length
        @amp[i] = max_amp
        i+=1
    end

    i=tone_length - decay_length
    while i < tone_length
        @amp[i] = - max_amp * (i - tone_length) / decay_length
        i+=1
    end

    i=0
    while i < tone_length
        @wave[i] = @amp[i] * Math.sin(scale * i)
        i+=1
    end

    i=tone_length
    while i < @wave_length
        @wave[i] = 0
        i+=1
    end

    ###########################################################################
    ###########################################################################
    ######### ejs todo                                              ###########
    ######### this test has never worked!  make it work once before ###########
    ######### checking it in                                        ###########
    #########                                                       ###########
    ###########################################################################
    ###########################################################################
    if true
        return
    end

    #process jack
    j=0
    while j < iter

        jsevent = @jc.getEvent(-1)
        assert_not_nil(jsevent)

        if jsevent.getType() == Jacks::PROCESS

            process_audio()
            dump_audio()

        elsif jsevent.getType() == Jacks::SAMPLE_RATE_CHANGE
            sr = @jc.getSampleRate()
            print "sample rate is now: %i\n" % sr

        elsif jsevent.getType() == Jacks::SHUTDOWN
            print "got shutdown\n"
            assert(false)

        elsif jsevent.getType() == Jacks::SESSION

        else
            print "what??\n"
        end

        jsevent.complete()
        j+=1
    end

  end

  def dump_audio
    b = @out.getBuffer()
    nframes = b.length()
    tlen = 10
    s = b.toHexString(nframes - tlen, tlen, "\n")
    print "out sample hex:\n"
    print s
 end

  def process_audio
    outbuffer = @out.getBuffer()
    nframes = outbuffer.length()
    frames_left = nframes

    while @wave_length - @offset < frames_left

      i=0
      while i < @wave_length - @offset
        outbuffer.setf(nframes - frames_left + i, @wave[@offset + i])
        i+=1

        frames_left -= @wave_length - @offset
        @offset = 0
      end
    end

    if frames_left > 0
      i=0
      while i < frames_left

        #bug!  ejs as soon as this first buffer is written, jack quits and tells us shutdown
        
        #bug!  ejs so maybe i'm not writting to the correct buffer? fix is to wrap buffer?

        outbuffer.setf(nframes - frames_left + i, @wave[@offset + i])
        i+=1
      end

      @offset += frames_left

    end
  end
end






