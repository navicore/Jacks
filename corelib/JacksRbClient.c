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
#include "JacksRbClient.h"
#include "JacksRbPort.h"
#include "JacksEvent.h"
#include "liblfds.h"
#include "JacksLatch.h"
#include <jack/jack.h>
#include <jack/session.h>
#include <jack/transport.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>
#include <pthread.h>
#include <semaphore.h>

#define T JacksRbClient

struct T {

    JacksRbPort **ports;
    int nports;
    jack_nframes_t rb_size;

    jack_client_t *client;

    struct queue_state *event_queue;
    sem_t mutex;

    JacksEvent process_event;

    JacksEvent session_event;
    JacksLatch session_latch;

    JacksEvent sample_rate_event;

    JacksEvent shutdown_event;

    volatile int activated;
};

static void _error (const char *desc) {

    fprintf (stderr, "JACK error: %s\n", desc); //i18n
}

static int _process_cb (jack_nframes_t nframes, void *arg) {

    T _this_ = (T) arg;

    for (int i = 0; i < _this_->nports; i++) {
        int rc = JacksRbPort_write_to_ringbuffer(_this_->ports[i], nframes);
        if (rc) {
            //todo: fatal error txt
            fprintf (stderr, "JACK write to ringbuffer error. rc: %i\n", rc); //i18n
            return -1;
        }
        rc = queue_enqueue(_this_->event_queue, _this_->process_event);
        if (rc != 1) {
            //todo: fatal error txt
            return -1;
        }
        sem_post(&_this_->mutex);
    }

    return 0;      
}

static void _session_cb(jack_session_event_t *event, void *arg) {

    T _this_ = (T) arg;

    JacksEvent_set_data(_this_->session_event, event);
    queue_enqueue(_this_->event_queue, _this_->session_event);
    sem_post(&_this_->mutex);

    JacksLatch_get(_this_->session_latch);
    JacksEvent_set_data(_this_->session_event, NULL);

    jack_session_reply(_this_->client, event);
    jack_session_event_free(event);
}

static void _shutdown_cb (void *arg) {

    T _this_ = (T) arg;

    queue_enqueue(_this_->event_queue, _this_->shutdown_event);
    sem_post(&_this_->mutex);
}

static int _sample_rate_change_cb(jack_nframes_t nframes, void *arg) {

    T _this_ = (T) arg;

    queue_enqueue(_this_->event_queue, _this_->sample_rate_event);
    sem_post(&_this_->mutex);

    return 0;
}

//
//api
//

JacksEvent JacksRbClient_get_event(T _this_, long timeout) {

    //todo: timeout
    JacksEvent je;

    while ( !queue_dequeue(_this_->event_queue, &je) ) {

        sem_wait(&_this_->mutex);       /* down semaphore */

    }

    return je;
}

jack_nframes_t JacksRbClient_get_sample_rate(T _this_) {

    return jack_get_sample_rate(_this_->client);
}

T JacksRbClient_new( const char *name, 
                     const char *option_str, 
                     jack_options_t option, 
                     jack_nframes_t rb_size) {

    T _this_;
    _this_ = malloc(sizeof *_this_);

    _this_->ports = malloc(MAX_PORTS * sizeof(JacksRbPort)); //todo: max size
    _this_->nports = 0;
    _this_->activated = NO;
    if (rb_size) {
        _this_->rb_size = rb_size;
    } else {
        _this_->rb_size = DEFAULT_RB_SIZE;
    }

    queue_new(&_this_->event_queue, _this_->rb_size);
    sem_init(&_this_->mutex, 0, 1); //binary semephore

    _this_->process_event = JacksEvent_new(PROCESS, NULL, NULL);

    _this_->session_latch = JacksLatch_new();
    _this_->session_event = JacksEvent_new(SESSION, JacksLatch_post, 
                                                _this_->session_latch);

    _this_->sample_rate_event = JacksEvent_new(SAMPLE_RATE_CHANGE, NULL, NULL);

    _this_->shutdown_event = JacksEvent_new(SHUTDOWN, NULL, NULL);

    jack_status_t status;

    _this_->client = jack_client_open (name, option, &status, option_str);
    if (_this_->client == NULL) {
        fprintf (stderr, "jack_client_open() failed, " //i18n
                 "status = 0x%2.0x\n", status);
        if (status & JackServerFailed) {
            fprintf (stderr, "Unable to connect to JACK server\n");
        }
        exit (1);
    }
    if (status & JackServerStarted) {
        fprintf (stderr, "JACK server started\n");
    }
    if (status & JackNameNotUnique) {
        char *uniquename = jack_get_client_name(_this_->client);
        fprintf (stderr, "unique name `%s' assigned\n", uniquename);
    }

    //
    //configure callbacks
    //

    jack_on_shutdown (_this_->client, _shutdown_cb, _this_);

    jack_set_sample_rate_callback(_this_->client, _sample_rate_change_cb, _this_);

    jack_set_session_callback (_this_->client, _session_cb, _this_);

    jack_set_error_function(_error);

    return _this_;
}

/*
void JacksRbClient_set_rb_size(T _this_, jack_nframes_t rb_size) {

    _this_->rb_size = rb_size;
}
*/
jack_nframes_t JacksRbClient_get_rb_size(T _this_) {

    return _this_->rb_size;
}


JacksRbPort JacksRbClient_registerPort(T _this_, char *name, unsigned long options) {

    JacksRbPort jp = JacksRbPort_new_port(name, options, _this_, _this_->rb_size);
    assert(jp);
    _this_->ports[_this_->nports] = jp;
    _this_->nports++;
    return jp;
}

int JacksRbClient_activate(T _this_, int process_audio) {

    if (_this_->activated == YES) {
        fprintf (stderr, "already activated\n");
        return -1;
    }
    if (process_audio == YES) {
        jack_set_process_callback (_this_->client, _process_cb, _this_);
        _this_->activated = YES;
    }
    return jack_activate(_this_->client);
}

char *JacksRbClient_get_name(T _this_) {

    return jack_get_client_name(_this_->client);
}

jack_client_t *JacksRbClient_get_client(T _this_) {

    return _this_->client;
}


void JacksRbClient_free(T *_this_p_) {

    assert(_this_p_ && *_this_p_);
    T _this_ = *_this_p_;

    jack_client_close (_this_->client);

    JacksEvent_free(&_this_->process_event);

    JacksLatch_free(&_this_->session_latch);
    JacksEvent_free(&_this_->session_event);

    JacksEvent_free(&_this_->sample_rate_event);

    JacksEvent_free(&_this_->shutdown_event);

    free(_this_);
}


#undef T

