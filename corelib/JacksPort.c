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
#include "JacksPort.h"
#include "JacksClient.h"
#include <jack/jack.h>
#include <jack/types.h>
#include <jack/session.h>
#include <jack/transport.h>
#include <jack/ringbuffer.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>

#define T JacksPort

struct T {
    jack_port_t *jport;
    JacksClient jackclient;
};

// contructor/wrapper for existing ports the user looks up
T JacksPort_new(jack_port_t *jport, JacksClient jackclient) {

    T _this_ = malloc(sizeof *_this_);
    if (_this_ == NULL) {
        fprintf (stderr, "JacksPort_new: can not alloc event\n");
        return NULL;
    }

    _this_->jport = jport;
    _this_->jackclient = jackclient;

    return _this_;
}

// contstructor for ports the user creates
T JacksPort_new_port(const char *name, unsigned long options, JacksClient jackclient) {

    //todo: midi option
    jack_port_t *jport = jack_port_register(JacksClient_get_client(jackclient), name, 
                                           JACK_DEFAULT_AUDIO_TYPE, options, 0);

    return JacksPort_new(jport, jackclient);
}

void JacksPort_free(T *_this_p_) {
    assert(_this_p_ && *_this_p_);
    T _this_ = *_this_p_;
    free(_this_);
}

int JacksPort_connect(T _this_, T _that_) {

    int rc = 0;

    if (jack_connect(JacksClient_get_client(_this_->jackclient), 
                     jack_port_name(_this_->jport), 
                     jack_port_name (_that_->jport))) {
        fprintf (stderr, "cannot connect ports\n");
        rc = -1;
    }

    return rc;
}

sample_t* JacksPort_get_buffer(T _this_) {

    jack_nframes_t nframes = JacksClient_get_nframes(_this_->jackclient);

    return jack_port_get_buffer(_this_->jport, nframes);
}


#undef T

