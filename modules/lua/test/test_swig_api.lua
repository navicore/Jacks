#!/usr/bin/lua

require "jacks"
require "sndfile"

jc = jacks.JsClient("lua_unit_test", nil, jacks.JackNullOption, 0)
assert(jc ~= nil)

samplerate = jc:getSampleRate()
print("sample rate is", samplerate)

sf = sndfile.SndFile(samplerate, 1, 0, "./myfile.wav")

running = true

while running do

    jsevent = jc:getEvent(-1)
    assert(jsevent ~= nil)

    if jsevent:getType() == jacks.PROCESS then

        -- process_audio()
        -- dump_audio()

    elseif jsevent:getType() == jacks.SAMPLE_RATE_CHANGE then
        sr = jc:getSampleRate()
        print("sample rate is now ", sr)
        running = false; --quick test

    elseif jsevent:getType() == jacks.SHUTDOWN then
        print("shutdown");
        running = false;

    else 
        print "what??\n"
    end

    jsevent:complete()

end

