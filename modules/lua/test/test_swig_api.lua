#!/usr/bin/lua

require "jacks"

local floor = math.floor
function bxor (a,b)
  local r = 0
  for i = 0, 31 do
    local x = a / 2 + b / 2
    if x ~= floor (x) then
      r = r + 2^i
    end
    a = floor (a / 2)
    b = floor (b / 2)
  end
  return r
end


iter            = 100

freq            = 680
max_amp         = 0.5
dur_arg         = 100
attack_percent  = 2
decay_percent   = 40
transport_aware = 0
got_bpm         = 200
PI              = 3.14

jc = jacks.JsClient("lua_unit_test", nil, jacks.JackNullOption)
assert(jc ~= nil)

out = jc:registerPort("output", jacks.JackPortIsOutput)
jc:activate()

speaker = jc:getPortByType("sys", "", bxor(jacks.JackPortIsPhysical,
                                           jacks.JackPortIsInput), 0)
assert(speaker ~= nil)
rc = out:connect(speaker)
assert(rc == 0)

--
-- setup wave table parameters
--

wave_length     = 60 * jc:getSampleRate() / got_bpm
tone_length     = jc:getSampleRate() * dur_arg / 1000
attack_length   = tone_length * attack_percent / 100
decay_length    = tone_length * decay_percent / 100
scale           = 2 * PI * freq / jc:getSampleRate()

print("values wave_length ", wave_length, "tone_length", tone_length, "attack_length", attack_length, "decay_length", decay_length, "scale", scale)

if (tone_length >= wave_length) then
    assert(false, "invalid tone_length / wave_length")
end

if (attack_length + decay_length > tone_length) then
    assert(false, "invalid attack_length / decay_length / tone_length")
end

amp = {} 
for i=0, tone_length do
    amp[i] = 0
end

wave = {}
for i=0, wave_length do
    wave[i] = 0
end

--
-- Build the wave table
--

for i=0, attack_length do
    amp[i] = max_amp * i / attack_length
end

for i=attack_length, tone_length - decay_length do
    amp[i] = max_amp
end

for i=tone_length - decay_length, tone_length do
    amp[i] = - max_amp * (i - tone_length) / decay_length
end

for i=0, tone_length do
    wave[i] = amp[i] * math.sin(scale * i)
end

for i=tone_length, wave_length do
    wave[i] = 0
end

offset = 0
function process_audio()
    outbuffer = out:getBuffer()
    nframes = outbuffer:length()
    frames_left = nframes

    while wave_length - offset < frames_left do

        for i=0, wave_length - offset do
            outbuffer:setf(nframes - frames_left + i, wave[offset + i])
        end

        frames_left = frames_left - (wave_length - offset)
        offset = 0
    end

    if frames_left > 0 then
        for i=0, frames_left do
            outbuffer:setf(nframes - frames_left + i,wave[offset + i])
        end

        offset = offset + frames_left
    end

end

function dump_audio()

    b = out:getBuffer()
    nframes = b:length()
    len = 10
    s = b:toHexString(nframes - len, len, '\n')
    print("out sample hex:")
    print(s)

end

for j=0, iter do

    jsevent = jc:getEvent(-1)
    assert(jsevent ~= nil)

    if jsevent:getType() == jacks.PROCESS then

        process_audio()
        -- dump_audio()

    elseif jsevent:getType() == SAMPLE_RATE_CHANGE then
        sr = jc:getSampleRate()
        print("sample rate is now ", sr)

    else 
        print "what??\n"
    end

    jsevent:complete()

end

