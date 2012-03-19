#!/usr/bin/python3
import jacks
from jacks import *
import math
import time

jc = JsClient("python_unit_test", None, JackNullOption)
if jc == None: raise AsertionError

iter            = 100

freq            = 1080
max_amp         = 0.5
dur_arg         = 100
attack_percent  = 1
decay_percent   = 10
transport_aware = 0
got_bpm         = 400
PI              = 3.14

out = jc.registerPort("output", JackPortIsOutput);
jc.activate();

speaker = jc.getPortByType("sys", "", JackPortIsPhysical | JackPortIsInput, 0);
if speaker == None: raise AsertionError
rc = out.connect(speaker);
if rc : raise AsertionError

#
# setup wave table parameters
#
wave_length     = 60 * jc.getSampleRate() / got_bpm
tone_length     = jc.getSampleRate() * dur_arg / 1000
attack_length   = tone_length * attack_percent / 100
decay_length    = tone_length * decay_percent / 100
scale           = 2 * PI * freq / jc.getSampleRate()

if tone_length >= wave_length:
    raise AsertionError("invalid tone_length / wave_length\n")

if attack_length + decay_length > tone_length:
    raise AsertionError("invalid attack_length / decay_length / tone_length\n")

amp = []
i=0
while i < tone_length:
    #this is bs, why do i need to init?
    amp.append(0)
    i+=1

wave = []
i=0
while i < wave_length:
    #this is bs, why do i need to init?
    wave.append(0)
    i+=1

#
# Build the wave table
#

i=0
while i < int(attack_length):
    amp[i] = max_amp * i / attack_length
    i+=1

i=int(attack_length)
while i < tone_length - decay_length:
    amp[i] = max_amp
    i+=1

i=int(tone_length - decay_length)
while i < tone_length:
    amp[i] = - max_amp * (i - tone_length) / decay_length
    i+=1

i=0
while i < tone_length:
    wave[i] = amp[i] * math.sin(scale * i)
    i+=1

i=int(tone_length)
while i < wave_length:
    wave[i] = 0
    i+=1

offset          = 0
def process_audio():
    global offset
    outbuffer = out.getBuffer()
    nframes = outbuffer.length()
    frames_left = nframes

    while (wave_length - offset < frames_left):

        i=0
        while i < wave_length - offset:
            outbuffer.setf(int(nframes - frames_left + i), wave[int(offset + i)])
            i+=1

        frames_left -= wave_length - offset
        offset = 0

    if frames_left > 0:
        i=0
        while i < frames_left:
            val = wave[int(offset + i)]
            pos = int(nframes - frames_left + i)
            outbuffer.setf(pos, val)
            i+=1

        offset += frames_left

def dump_audio():
    b = out.getBuffer()
    nframes = b.length()
    tlen = 10
    s = b.toHexString(nframes - tlen, tlen, '\n')
    print("out sample hex:")
    print(s)

j=0
while j < iter:

    jsevent = jc.getEvent(-1)
    if jsevent == None: raise AsertionError

    if jsevent.getType() == PROCESS:

        process_audio()
        #dump_audio()

    elif jsevent.getType() == SAMPLE_RATE_CHANGE:
        sr = jc.getSampleRate()
        print("sample rate is now: %i\n" % sr)

    else:
        print("what??\n")

    jsevent.complete()
    j+=1


