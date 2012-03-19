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

#ifndef JACKCLIENT_H
#define JACKCLIENT_H

#include "config.h"
#include "JacksEvent.h"
#include <jack/jack.h>
#include <jack/session.h>
#include <jack/transport.h>
#include <assert.h>

#define T JacksClient
typedef struct T *T;

extern T                JacksClient_new(const char *, const char *, jack_options_t);

#define YES 1
#define NO 0

typedef enum JACKSCRIPT_EVENT_TYPE {
    PROCESS, SESSION, ERR, SAMPLE_RATE_CHANGE, SHUTDOWN
} JACKSCRIPT_EVENT_TYPE;

extern void             JacksClient_free(T *);

extern JacksEvent  JacksClient_get_event(T, long);

extern jack_nframes_t   JacksClient_get_nframes(T);

extern jack_nframes_t   JacksClient_get_sample_rate(T);

extern jack_default_audio_sample_t *JacksClient_get_in_buffer(T);

extern void             JacksClient_set_out_buffer(T, jack_default_audio_sample_t *);

extern jack_default_audio_sample_t *JacksClient_get_out_buffer(T);

extern jack_client_t   *JacksClient_get_client(T);

extern int              JacksClient_activate(T, int);

extern char             *JacksClient_get_name(T);

#undef T
#endif

