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
#include "JacksClient.h"
#include "JacksEvent.h"
#include "JacksEventQueue.h"
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

#define T JacksClient

struct T {

    jack_client_t *client;
    jack_nframes_t sample_rate;

    jack_nframes_t nframes; //set this every process_cb

    pthread_mutex_t lock;
    pthread_cond_t  cond;

    JacksEventQueue event_queue;

    JacksEvent process_event;
    JacksLatch process_latch;

    JacksEvent session_event;
    JacksLatch session_latch;

    JacksEvent sample_rate_event;

    JacksEvent shutdown_event;

    int process_audio;
    int activated;
};

static void _lock( T _this_) {
    pthread_mutex_lock(&_this_->lock);
}

static void _unlock( T _this_) {
    pthread_cond_signal(&_this_->cond);
    pthread_mutex_unlock(&_this_->lock);
}

static void _error (const char *desc) {

    fprintf (stderr, "JACK error: %s\n", desc); //i18n
}

static int _process_cb (jack_nframes_t nframes, void *arg) {

    T _this_ = (T) arg;
    _lock(_this_);
    _this_->nframes = nframes;
    _unlock(_this_);

    JacksEventQueue_put(_this_->event_queue, _this_->process_event);
    JacksLatch_get(_this_->process_latch);

    return 0;      
}

void _session_cb(jack_session_event_t *event, void *arg) {

    T _this_ = (T) arg;

    JacksEvent_set_data(_this_->session_event, event);
    JacksEventQueue_put(_this_->event_queue, _this_->session_event);

    JacksLatch_get(_this_->session_latch);
    JacksEvent_set_data(_this_->session_event, NULL);

    jack_session_reply(_this_->client, event);
    jack_session_event_free(event);
}

static void _shutdown_cb (void *arg) {

    T _this_ = (T) arg;

    JacksEventQueue_put(_this_->event_queue, _this_->shutdown_event);
}

static int _sample_rate_change_cb(jack_nframes_t nframes, void *arg) {

    T _this_ = (T) arg;

    _lock(_this_);

    _this_->sample_rate = nframes;

    _unlock(_this_);

    JacksEventQueue_put(_this_->event_queue, _this_->sample_rate_event);

    return 0;
}

//
//api
//

JacksEvent JacksClient_get_event(T _this_, long timeout) {

    return JacksEventQueue_get(_this_->event_queue, timeout);
}

jack_nframes_t JacksClient_get_nframes(T _this_) {

    jack_nframes_t ret;

    _lock(_this_);

    ret = _this_->nframes;

    _unlock(_this_);

    return ret;
}

jack_nframes_t JacksClient_get_sample_rate(T _this_) {

    jack_nframes_t ret;

    _lock(_this_);

    ret = _this_->sample_rate;

    _unlock(_this_);

    return ret;
}

T JacksClient_new( const char *name, const char *option_str, jack_options_t option) {

    T _this_;
    _this_ = malloc(sizeof *_this_);

    pthread_mutex_init(&_this_->lock, NULL);
    pthread_cond_init(&_this_->cond, NULL);

    _this_->process_audio = NO;
    _this_->activated = NO;

    _this_->event_queue = JacksEventQueue_new();

    _this_->process_latch = JacksLatch_new();
    _this_->process_event = JacksEvent_new(PROCESS, JacksLatch_post, 
                                                _this_->process_latch);

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

    _this_->sample_rate = jack_get_sample_rate (_this_->client);

    return _this_;
}

int JacksClient_activate(T _this_, int process_audio) {

    _lock(_this_);
    if (_this_->activated == YES) {
        fprintf (stderr, "already activated\n");
        return -1;
    }
    if (process_audio == YES) {
        jack_set_process_callback (_this_->client, _process_cb, _this_);
        _this_->activated = YES;
    }
    _unlock(_this_);
    return jack_activate(_this_->client);
}

char *JacksClient_get_name(T _this_) {

    return jack_get_client_name(_this_->client);
}

jack_client_t *JacksClient_get_client(T _this_) {

    return _this_->client;
}


void JacksClient_free(T *_this_p_) {

    assert(_this_p_ && *_this_p_);
    T _this_ = *_this_p_;

    pthread_mutex_destroy( &_this_->lock );
    pthread_cond_destroy( &_this_->cond );

    jack_client_close (_this_->client);

    JacksLatch_free(&_this_->process_latch);
    JacksEvent_free(&_this_->process_event);

    JacksLatch_free(&_this_->session_latch);
    JacksEvent_free(&_this_->session_event);

    JacksEvent_free(&_this_->sample_rate_event);

    JacksEvent_free(&_this_->shutdown_event);

    JacksEventQueue_free(&_this_->event_queue);

    free(_this_);
}


#undef T

