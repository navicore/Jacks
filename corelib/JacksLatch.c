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
#include "JacksLatch.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <pthread.h>
#include <assert.h>

#define T JacksLatch

#define NOT_POSTED 0
#define POSTED 1

struct T {
    int status;
    pthread_mutex_t latchlock;
    pthread_cond_t  latchcond;
};

T JacksLatch_new() {

    T _this_ = malloc(sizeof *_this_);
    if (_this_ == NULL) {
        fprintf (stderr, "JacksLatch_new: can not alloc event\n");
        return NULL;
    }

    _this_->status = NOT_POSTED;

    pthread_mutex_init(&_this_->latchlock, NULL);
    pthread_cond_init(&_this_->latchcond, NULL);

    return _this_;
}

int JacksLatch_get(T _this_) {

    int rc = 0;

    pthread_mutex_lock(&_this_->latchlock);

    while (_this_->status != POSTED) {
        pthread_cond_wait(&_this_->latchcond, &_this_->latchlock);
    }

    _this_->status = NOT_POSTED;

    pthread_cond_signal(&_this_->latchcond);
    pthread_mutex_unlock(&_this_->latchlock);

    return rc;
}

int JacksLatch_post(T _this_) {

    pthread_mutex_lock(&_this_->latchlock);

    _this_->status = POSTED;

    pthread_cond_signal(&_this_->latchcond);
    pthread_mutex_unlock(&_this_->latchlock);

    return 0;
}

void JacksLatch_free(T *_this_p_) {

    assert(_this_p_ && *_this_p_);

    T _this_ = *_this_p_;

    pthread_mutex_destroy( &_this_->latchlock );
    pthread_cond_destroy( &_this_->latchcond );

    free(_this_);
}

#undef T

