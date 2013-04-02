#!/usr/bin/lua

require "jacks"

jc = jacks.JsClient("lua_unit_test", nil, jacks.JackNullOption, 0)
assert(jc ~= nil)

samplerate = jc:getSampleRate()
print("sample rate is", samplerate)

port_name_list = jc:getPortNames("play")
assert(port_name_list ~= nil)
port1 = jc:getPort(port_name_list:get(0))
assert(port1 ~= nil)
print("port1 name is ", port1:name())

port_name_list = jc:getPortNames("cap")
assert(port_name_list ~= nil)
port2 = jc:getPort(port_name_list:get(0))
assert(port2 ~= nil)
print("port2 name is ", port2:name())

--[[
port2:connect(port1)

lat_port = port1:initLatencyListener()
assert(lat_port ~= nil)
--lat_port = port1:initLatencyListener()

os.execute("sleep 1")
port1:wakeup()

port1:setLatencyRange(jacks.JackPlaybackLatency, 64, 64)
port2:setLatencyRange(jacks.JackPlaybackLatency, 64, 64)
port1:setLatencyRange(jacks.JackCaptureLatency, 64, 64)
port2:setLatencyRange(jacks.JackCaptureLatency, 64, 64)

os.execute("sleep 3")
jc:recomputeLatencies()
os.execute("sleep 3")
]]--
