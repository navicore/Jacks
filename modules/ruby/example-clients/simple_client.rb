#!/usr/bin/ruby
require 'jacks'

class SimpleClient

  def main

  	@jc = Jackscript::JsClient.new("simple", nil, Jackscript::JackNullOption)

    @out = @jc.registerPort("output", Jackscript::JackPortIsOutput)
    @in = @jc.registerPort("input", Jackscript::JackPortIsInput)
    @jc.activate()

    while true

        jsevent = @jc.getEvent(-1)

        if jsevent.getType() == Jackscript::PROCESS

            inbuffer = @in.getBuffer()

            outbuffer = @out.getBuffer()

            nframes = outbuffer.length()

            i=0
            while i < nframes 

              s = inbuffer.getf(i)

              outbuffer.setf(i, s)

              i+=1
            end

        elsif jsevent.getType() == Jackscript::SAMPLE_RATE_CHANGE
            sr = @jc.getSampleRate()
            print "sample rate is now: %i\n" % sr

        elsif jsevent.getType() == Jackscript::SHUTDOWN
            print "got shutdown\n"
            assert(false)

        elsif jsevent.getType() == Jackscript::SESSION

        else
            print "what??\n"
        end

        jsevent.complete()

    end

  end

end

r = SimpleClient.new()
r.main
