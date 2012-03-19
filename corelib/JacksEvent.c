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
#include "JacksEvent.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>

#define T JacksEvent

struct T {
    int etype;
    void *data;
    JSEVENT_CTOKEN *ctoken;
    void *ctoken_arg;
};

T JacksEvent_new(int etype, JSEVENT_CTOKEN *ctoken, void *ctoken_arg) {

    T _this_ = malloc(sizeof *_this_);
    if (_this_ == NULL) {
        fprintf (stderr, "JacksEvent_new: can not alloc event\n");
        return NULL;
    }

    _this_->etype       = etype;
    _this_->data        = NULL;
    _this_->ctoken      = ctoken;
    _this_->ctoken_arg  = ctoken_arg;

    return _this_;
}

void JacksEvent_free(T *_this_p_) {
    assert(_this_p_ && *_this_p_);
    T _this_ = *_this_p_;
    free(_this_);
}

void JacksEvent_complete(T _this_) {

    if (_this_->ctoken == NULL) return;

    _this_->ctoken(_this_->ctoken_arg);
}

int JacksEvent_get_type(T _this_) {
    return _this_->etype;
}

void *JacksEvent_get_data(T _this_) {
    return _this_->data;
}

void JacksEvent_set_data(T _this_, void *data) {
    _this_->data = data;
}


#undef T

