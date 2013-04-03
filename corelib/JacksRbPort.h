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
#ifdef __cplusplus
extern "C" {
#endif 


#ifndef _JS_RB_PORT_H_
#define _JS_RB_PORT_H_

#include "config.h"
#include "JacksRbClient.h"
#include <jack/jack.h>
#include <assert.h>

#define T JacksRbPort
typedef struct T *T;

extern T            JacksRbPort_new(jack_port_t *, JacksRbClient, jack_nframes_t);

extern T            JacksRbPort_new_port(const char *, 
                                         unsigned long, JacksRbClient, jack_nframes_t);

extern void         JacksRbPort_free(T *);

extern int          JacksRbPort_connect(T, T);

extern int          JacksRbPort_write_to_ringbuffer(T, jack_nframes_t);

extern sample_t*    JacksRbPort_read_from_ringbuffer(T, int*);

extern void*        JacksRbPort_get_port(T);

extern int          JacksRbPort_init_latency_listener(T);
extern int          JacksRbPort_init_latency_listener_fd(T);

extern void         JacksRbPort_wakeup(T); //ejs test
extern void         JacksRbPort_wakeup_fd(T); //ejs test

#undef T
#endif

#ifdef __cplusplus
}
#endif 

