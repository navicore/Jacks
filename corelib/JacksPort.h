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

#ifndef _JSPORT_H_
#define _JSPORT_H_

#include "config.h"
#include "JacksClient.h"
#include <jack/jack.h>
#include <jack/session.h>
#include <jack/transport.h>
#include <assert.h>

#define T JacksPort
typedef struct T *T;

typedef jack_default_audio_sample_t sample_t;

extern T            JacksPort_new(jack_port_t *, JacksClient);

extern T            JacksPort_new_port(const char *, unsigned long, JacksClient);

extern void         JacksPort_free(T *);

extern int          JacksPort_connect(T, T);

//extern int          JacksPort_write_to_ringbuffer(T);

//extern sample_t*    JacksPort_read_from_ringbuffer(T);

extern sample_t*    JacksPort_get_buffer(T);

#undef T
#endif

