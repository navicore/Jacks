#!/usr/bin/ruby
require 'test/unit'
require 'jacks'

class TestJacksMetronome < Test::Unit::TestCase

  def test_runme

  	@jc = Jacks::JsClient.new("ruby_metronome_unit_test", nil, 
    Jacks::JackNullOption, 0)
	assert_not_nil(@jc)

    iter            = 100

    #process jack
    j=0
    while j < iter

        jsevent = @jc.getEvent(-1)
        assert_not_nil(jsevent)

        if jsevent.getType() == Jacks::PROCESS

            #process_audio()
            #dump_audio()

        elsif jsevent.getType() == Jacks::SAMPLE_RATE_CHANGE
            sr = @jc.getSampleRate()
            print "sample rate is now: %i\n" % sr
            j = iter #quick test

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
end

