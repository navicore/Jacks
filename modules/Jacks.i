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

%module jacks

%{
#include "config.h"
#include <jack/jack.h>
#include <jack/session.h>
#include <jack/transport.h>
#include <stdbool.h>
#include <string.h>
#include <string.h>
#include "JacksRbClient.h"
#include "JacksEvent.h"
#include "JacksRbPort.h"
#include "Jacks.h"
    %}


%include "jack_exceptions.h"
%include "jack_headers.h"
#define VERSION VERSION

typedef struct {
    %extend {
        ~JsPortBuffer() {
            free($self);
        }

        const float* getf(unsigned int i) {
            return(float*) $self->framebuf[i];
        }

        void setf(unsigned int i, float val) {

            throw_exception("unsupported opperation");
            return;
        }

        unsigned int length() {
            return $self->len;
        }

        //for debug only!  dangerously presumes float is of len long
        //using this to compair test scripts written in different swig langs
        char* toHexString(unsigned int start, unsigned int len, char sep) {
            float* b = (float*) $self->framebuf;
            int dlen = 12;
            char *hex_text = malloc(dlen * len + 1);
            for (int i = 0; i < len ; i++) {

                char *pos = hex_text + dlen * i;

                if (sep) {
                    sprintf( pos, "0x%8.8XL%c", *((long*)&b[start + i]), sep ) ;
                } else {
                    sprintf( pos, "0x%8.8XL ", *((long*)&b[start + i]) ) ;
                }
            }
            return hex_text;
        }
    }
} JsPortBuffer;

typedef struct {
    %extend {
        ~JsLatencyRange() {
            free($self);
        }

        int min() {
            return $self->rmin;
        }

        int max() {
            return $self->rmax;
        }
    }
} JsLatencyRange;

typedef struct {
    %extend {
        ~StringList() {
            free($self->impl);
            free($self);
        }

        const char* get(int pos) {
            return $self->impl[pos];
        }

        size_t length() {
            if (!$self->len) {
                for (int i = 0;;i++) {
                    if ($self->impl[i] == NULL) {
                        $self->len = i;
                        break;
                    }
                }
            }
            return $self->len;
        }
    }
} StringList;

typedef struct {
    %extend {
        ~JsPort() {
            JacksRbPort_free(&$self->impl);
            free($self);
        }

        JsPortBuffer* getBuffer() {
            JsPortBuffer *holder;
            holder = malloc(sizeof(JsPortBuffer));
            int len = 0;
            holder->framebuf = JacksRbPort_read_from_ringbuffer($self->impl, &len);
            holder->len = len;
            return holder;
        }

        char* name() {
            return jack_port_name((jack_port_t *)JacksRbPort_get_port($self->impl));
        }

        int connect(JsPort *_that_) {

            return JacksRbPort_connect($self->impl, _that_->impl);
        }

        JsLatencyRange *getLatencyRange(enum JackLatencyCallbackMode mode) {

            jack_latency_range_t range;
            jack_port_get_latency_range((jack_port_t *) JacksRbPort_get_port($self->impl),
                                        mode, &range);

            JsLatencyRange *holder;
            holder = malloc(sizeof(JsLatencyRange));
            holder->rmin = (int) range.min; //todo: float?
            holder->rmax = (int) range.max;
            return holder;
        }
        void setLatencyRange(enum JackLatencyCallbackMode mode, int rmin, int rmax) { //todo: float

            jack_latency_range_t range;
            range.min = rmin;
            range.max = rmax;
            jack_port_set_latency_range((jack_port_t *) JacksRbPort_get_port($self->impl),
                                                    mode, &range);
        }
    }
} JsPort;

typedef struct {
    %extend {
        ~JsEvent() {
            JacksEvent_free(&$self->impl);
            free($self);
        }

        ////////////////////////////////////////////////////////
        ///////////////// jacks event api /////////////////
        ////////////////////////////////////////////////////////
        enum JACKSCRIPT_EVENT_TYPE getType() {

            return JacksEvent_get_type((JacksEvent) $self->impl);
        }

        void *getData() {
            return JacksEvent_get_data((JacksEvent) $self->impl);
        }

        void complete() {
            JacksEvent_complete((JacksEvent) $self->impl);
        }

        /////////////////////////////////////////////////////
        ///////////////// session event api /////////////////
        /////////////////////////////////////////////////////


        jack_session_event_type_t getSessionEventType() {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            return se->type;
        }

        const char *getSessionDir() {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            return se->session_dir;
        }
        void setSessionDir(const char *dirname) {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            se->session_dir = dirname;
        }

        const char *getClientUuid() {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            return se->client_uuid;
        }
        void setClientUuid(const char *uuid) {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            se->client_uuid = uuid;
        }

        char *getCommandLine() {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            return se->command_line;
        }
        void setCommandLine(char *cmd) {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            se->command_line = strdup(cmd);
        }

        jack_session_flags_t getSessionEventFlags() {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            return se->flags;
        }
        void setSessionEventFlags(jack_session_flags_t flags) {
            jack_session_event_t *se = JacksEvent_get_data((JacksEvent) $self->impl);
            if (se == NULL) throw_exception("not a session event");
            se->flags = flags;
        }
    }
} JsEvent;

typedef struct {
    %extend {
        JsClient(const char *name, const char *option_str, 
                 jack_options_t option, unsigned int rb_size) {

            JacksRbClient j = JacksRbClient_new(name, option_str, option, 
                                                (jack_nframes_t) rb_size);

            JsClient *holder;
            holder = malloc(sizeof(JsClient));
            holder->impl = j;
            holder->process_audio = NO;
            return holder;
        }
        ~JsClient() {
            JacksRbClient_free(&$self->impl);
            free($self);
        }

        StringList *getPortNames(const char *namepattern) {

            jack_client_t *client = JacksRbClient_get_client($self->impl);

            const char **jports = jack_get_ports(client, namepattern, NULL, 0);
            if (jports == NULL) {
                return NULL;
            }

            StringList *holder;
            holder = malloc(sizeof(StringList));
            holder->impl = jports;
            holder->len = 0;
            return holder;
        }

        //untested
        JsPort *getPortByName(char *name) {

            if (name == NULL) return NULL;

            jack_port_t *jport = jack_port_by_name(JacksRbClient_get_client($self->impl), name);
            if (jport == NULL) return NULL;

            jack_nframes_t rb_size = JacksRbClient_get_rb_size($self->impl);
            JacksRbPort p = JacksRbPort_new(jport, $self->impl, rb_size);
            JsPort *holder;
            holder = malloc(sizeof(JsPort));
            holder->impl = p;
            return holder;
        }

        JsPort *registerPort(char *name, unsigned long options) {

            JacksRbPort p = JacksRbClient_registerPort($self->impl, name, options);
            JsPort *holder;
            holder = malloc(sizeof(JsPort));
            holder->impl = p;
            holder->clientimpl = $self->impl;
            $self->process_audio = YES;
            return holder;
        }

        JsEvent *getEvent(long timeout) {
            JacksEvent e = JacksRbClient_get_event($self->impl, timeout);
            JsEvent *holder;
            holder = malloc(sizeof(JsEvent));
            holder->impl = e;
            return holder;
        }

        //jack_nframes_t getSampleRate() {
        unsigned int getSampleRate() {
            return JacksRbClient_get_sample_rate($self->impl);
        }

        int activate() {
            return JacksRbClient_activate($self->impl, $self->process_audio);
        }

        char *getName() {
            return JacksRbClient_get_name($self->impl);
        }

        jack_transport_state_t getTransportState() {
            jack_position_t position; //todo: do something with this!
            jack_transport_state_t t = jack_transport_query(
                                                           JacksRbClient_get_client($self->impl), &position);
            return t;
        }


        void recomputeLatencies() {

            int rc = jack_recompute_total_latencies(JacksRbClient_get_client($self->impl));
            if (rc) throw_exception("can not recompute total latency");

            return;
        }
    }
} JsClient;

