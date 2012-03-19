#!/usr/bin/lua

require "jacks"

jc = jacks.JsClient("lua_simple_client", nil, jacks.JackNullOption)
assert(jc ~= nil)

in_port = jc:registerPort("input", jacks.JackPortIsInput)
out_port = jc:registerPort("output", jacks.JackPortIsOutput)

jc:activate()

while true do

    jsevent = jc:getEvent(-1)

    if jsevent:getType() == jacks.PROCESS then

        inbuffer = in_port:getBuffer()

        outbuffer = out_port:getBuffer()

        nframes = outbuffer:length()

        for i=0, nframes do

          s = inbuffer:getf(i)

          outbuffer:setf(i, s)

        end

    elseif jsevent:getType() == jacks.SESSION then
        print "got session event\n"

    elseif jsevent:getType() == jacks.SHUTDOWN then
        print "got shutdown event\n"

    elseif jsevent:getType() == jacks.SAMPLE_RATE_CHANGE then
        sr = jc:getSampleRate()
        print("sample rate is now ", sr)

    else
        print "what??\n"
    end

    jsevent:complete()

end

