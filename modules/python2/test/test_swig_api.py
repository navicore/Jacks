#!/usr/bin/python
import jacks
from jacks import *
import math
import time

jc = JsClient("python_unit_test", None, JackNullOption, 0)
if jc == None: raise AsertionError

iter            = 100

j=0
while j < iter:

    jsevent = jc.getEvent(-1)
    if jsevent == None: raise AsertionError

    if jsevent.getType() == PROCESS:

        process_audio()
        #dump_audio()

    elif jsevent.getType() == SAMPLE_RATE_CHANGE:
        sr = jc.getSampleRate()
        print "sample rate is now: %i\n" % sr
        j = iter #quick test

    elif jsevent.getType() == SHUTDOWN:
        print "shutdown\n"
        j = iter

    else:
        print "what??\n"

    jsevent.complete()
    j+=1


