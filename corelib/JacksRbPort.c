/*
 *  Copyright (C) 2012 Ed Sweeney
 *  
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2.1 of the License, or
 *  (at your option) any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program; if not, write to the Free Software 
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include "config.h"
#include "JacksRbPort.h"
#include "JacksRbClient.h"
#include <jack/jack.h>
#include <jack/types.h>
#include <jack/session.h>
#include <jack/transport.h>
#include <jack/ringbuffer.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>

#define T JacksRbPort

struct T {
    jack_nframes_t rb_size;
    jack_port_t *jport;
    JacksRbClient jackclient;
    jack_ringbuffer_t *rb;
    //void *framebuf;
    char *framebuf;
    volatile int overruns;
};

const size_t jacks_sample_size = sizeof(jack_default_audio_sample_t);

// contructor/wrapper for existing ports the user looks up
T JacksRbPort_new(jack_port_t *jport, JacksRbClient jackclient, jack_nframes_t rb_size) {

    T _this_ = malloc(sizeof *_this_);
    if (_this_ == NULL) {
        fprintf (stderr, "JacksRbPort_new: can not alloc event\n");
        return NULL;
    }

    _this_->rb_size = rb_size;
    _this_->jport = jport;
    _this_->jackclient = jackclient;
    _this_->framebuf = malloc(rb_size);

	_this_->rb = jack_ringbuffer_create(jacks_sample_size * rb_size);
    return _this_;
}

// contstructor for ports the user creates
T JacksRbPort_new_port(const char *name, 
                       unsigned long options, 
                       JacksRbClient jackclient,
                       jack_nframes_t rb_size) {

    //todo: midi option
    jack_port_t *jport = jack_port_register(JacksRbClient_get_client(jackclient), name, 
                                           JACK_DEFAULT_AUDIO_TYPE, options, 0);

    return JacksRbPort_new(jport, jackclient, rb_size);
}

void JacksRbPort_free(T *_this_p_) {
    assert(_this_p_ && *_this_p_);
    T _this_ = *_this_p_;
    free(_this_->framebuf);
    free(_this_);
}

int JacksRbPort_connect(T _this_, T _that_) {

    int rc = 0;

    if (jack_connect(JacksRbClient_get_client(_this_->jackclient), 
                     jack_port_name(_this_->jport), 
                     jack_port_name (_that_->jport))) {
        fprintf (stderr, "cannot connect ports\n");
        rc = -1;
    }

    return rc;
}

int JacksRbPort_write_to_ringbuffer(T _this_, jack_nframes_t nframes) {

    int rc = 0;

    void *buff = jack_port_get_buffer(_this_->jport, nframes);

    size_t write_size = jacks_sample_size * nframes;

    if (jack_ringbuffer_write (_this_->rb, buff, write_size) < write_size) {
        fprintf (stderr, "overrunning... need bigger ringbuffer\n");
         _this_->overruns++;
         rc = -1;
    }
    return rc;
}

sample_t* JacksRbPort_read_from_ringbuffer(T _this_, int *len) {

    size_t avail = jack_ringbuffer_read_space(_this_->rb);

    jack_nframes_t rb_size  = _this_->rb_size;
    size_t blen =  avail < rb_size ? avail : rb_size;

    jack_ringbuffer_read(_this_->rb, _this_->framebuf, blen);

    *len = blen;

    return _this_->framebuf;
}


#undef T

