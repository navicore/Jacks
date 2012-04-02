#!/usr/bin/python
import jacks
from jacks import *

jc = JsClient("python simple client", None, JackNullOption)
if jc == None: raise AsertionError


in_port = jc.registerPort("input", JackPortIsInput)

out_port = jc.registerPort("output", JackPortIsOutput)

jc.activate()

while True:

    jsevent = jc.getEvent(-1)

    if jsevent.getType() == PROCESS:

        inbuffer = in_port.getBuffer()

        outbuffer = out_port.getBuffer()

        nframes = outbuffer.length()

        i=0
        while i < nframes:

          s = inbuffer.getf(i)

          outbuffer.setf(i, s)

          i+=1

    elif jsevent.getType() == SESSION:
        print("got session event\n")

    elif jsevent.getType() == SHUTDOWN:
        print("got shutdown event\n")

    elif jsevent.getType() == SAMPLE_RATE_CHANGE:
        sr = jc.getSampleRate()
        print("sample rate is now: %i\n" % sr)

    else:
        print("what??\n")

    jsevent.complete()

