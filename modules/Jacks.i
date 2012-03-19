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
#include "JacksClient.h"
#include "JacksEvent.h"
#include "JacksPort.h"
#include "Jacks.h"
%}

%exception {
    char *err;
    clear_exception();
    $action
    if ((err = check_exception())) {
#if defined (SWIGPERL)
        croak(CROAK, err);
        return;
#elif defined (SWIGPYTHON)
        PyErr_SetString(PyExc_RuntimeError, err);
        return NULL;
#elif defined (SWIGRUBY)
        void *runerror = rb_define_class("JacksRuntimeError", rb_eStandardError);
        rb_raise(runerror, err);
        return;
#elif defined (SWIGLUA)
        luaL_error(L, err);
        return -1; 
#else
        assert(false);
        return;
#endif
    }
}

%include "jack_headers.h"
#define VERSION VERSION

typedef struct {
    %extend {
        ~JsPortBuffer() {
            free($self);
        }

        float getf(unsigned int i) {
            jack_default_audio_sample_t *b = JacksPort_get_buffer($self->portimpl);
            return (float) b[i];
        }

        void setf(unsigned int i, float val) {

            jack_default_audio_sample_t *b = JacksPort_get_buffer($self->portimpl);
            b[i] = (jack_default_audio_sample_t) val;
        }

        unsigned int length() {
            return JacksClient_get_nframes($self->clientimpl);
        }

        //for debug only!  dangerously presumes float is of len long
        //using this to compair test scripts written in different swig langs
        char* toHexString(unsigned int start, unsigned int len, char sep) {
            float* b = (float*) JacksPort_get_buffer($self->portimpl);
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
        ~JsPort() {
            JacksPort_free(&$self->impl);
            free($self);
        }

        JsPortBuffer* getBuffer() {
            JsPortBuffer *holder;
            holder = malloc(sizeof(JsPortBuffer));
            holder->portimpl = $self->impl;
            holder->clientimpl = $self->clientimpl;
            return holder;
        }

        int connect(JsPort *_that_) {

            return JacksPort_connect($self->impl, _that_->impl);
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
        JsClient(const char *name, const char *option_str, jack_options_t option) {

            JacksClient j = JacksClient_new(name, option_str, option);

            JsClient *holder;
            holder = malloc(sizeof(JsClient));
            holder->impl = j;
            holder->process_audio = NO;
            return holder;
        }
        ~JsClient() {
            JacksClient_free(&$self->impl);
            free($self);
        }

        //untested
        JsPort *getPortByType(const char *namepattern, 
                              const char *typepattern, unsigned long options, int pos) {

            jack_client_t *client = JacksClient_get_client($self->impl);

            const char **jports = jack_get_ports(client, namepattern, typepattern, options);
            if (jports == NULL) {
                 return NULL;
            }
            jack_port_t *jport = jack_port_by_name(client, jports[pos]);
            if (jport == NULL) return NULL;

            JacksPort p = JacksPort_new(jport, $self->impl);
            JsPort *holder;
            holder = malloc(sizeof(JsPort));
            holder->impl = p;
            free(jports);
            return holder;
        }

        //untested
        JsPort *getPortByName(char *name) {

            jack_port_t *jport = jack_port_by_name(JacksClient_get_client($self->impl), name);
            if (jport == NULL) return NULL;

            JacksPort p = JacksPort_new(jport, $self->impl);
            JsPort *holder;
            holder = malloc(sizeof(JsPort));
            holder->impl = p;
            return holder;
        }

        JsPort *registerPort(char *name, unsigned long options) {

            JacksPort p = JacksPort_new_port(name, options, $self->impl);
            JsPort *holder;
            holder = malloc(sizeof(JsPort));
            holder->impl = p;
            holder->clientimpl = $self->impl;
            $self->process_audio = YES;
            return holder;
        }

        JsEvent *getEvent(long timeout) {
            JacksEvent e = JacksClient_get_event($self->impl, timeout);
            JsEvent *holder;
            holder = malloc(sizeof(JsEvent));
            holder->impl = e;
            return holder;
        }

        //jack_nframes_t getSampleRate() {
        unsigned int getSampleRate() {
            return JacksClient_get_sample_rate($self->impl);
        }

        int activate() {
            return JacksClient_activate($self->impl, $self->process_audio);
        }

        char *getName() {
            return JacksClient_get_name($self->impl);
        }

        jack_transport_state_t getTransportState() {
            jack_position_t position; //todo: do something with this!
            jack_transport_state_t t = jack_transport_query(
                JacksClient_get_client($self->impl), &position);
            return t;
        }

    }
} JsClient;

