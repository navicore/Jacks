#!/usr/bin/lua

require "jacks"

jc = jacks.JsClient("lua_unit_test", nil, jacks.JackNullOption, 0)
assert(jc ~= nil)

samplerate = jc:getSampleRate()
print("sample rate is", samplerate)

port_name_list = jc:getPortNames("play")
assert(port_name_list ~= nil)
print("nports is ", port_name_list:length())
print("port name 1 is ", port_name_list:get(0))
print("port name 2 is ", port_name_list:get(1))
port1 = jc:getPort(port_name_list:get(0))
assert(port1 ~= nil)
print("port1 name is ", port1:name())
r = port1:getLatencyRange(jacks.JackCaptureLatency)
print("port1 latency min ", r:min())
print("port1 latency max ", r:max())

port_name_list = jc:getPortNames("cap")
--print("nports:", port_name_list:length())
port1 = jc:getPort(port_name_list:get(0))
assert(port1 ~= nil)
print("port1 name is ", port1:name())

-- test latency callback reg function
lat_port = port1:initLatencyListener()
assert(lat_port ~= nil)
--lat_port = port1:initLatencyListener()

r = port1:getLatencyRange(jacks.JackCaptureLatency)
print("port1 latency min ", r:min())
print("port1 latency max ", r:max())
port1:setLatencyRange(jacks.JackCaptureLatency, 64, 64)
r = port1:getLatencyRange(jacks.JackCaptureLatency)
print("port1 new latency min ", r:min())
print("port1 new latency max ", r:max())
jc:recomputeLatencies()
r = port1:getLatencyRange(jacks.JackCaptureLatency)
print("port1 new latency min ", r:min())
print("port1 new latency max ", r:max())

port1:setLatencyRange(jacks.JackCaptureLatency, 1024, 1024)
r = port1:getLatencyRange(jacks.JackCaptureLatency)
print("port1 new new latency min ", r:min())
print("port1 new new latency max ", r:max())

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

