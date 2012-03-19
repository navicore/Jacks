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
#include "JacksEventQueue.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <pthread.h>
#include <assert.h>

#define T JacksEventQueue

typedef struct q_entry {
    JacksEvent jsevent;
    struct q_entry *next;
} q_entry;

typedef struct jsqueue {
    q_entry *head;
    q_entry *tail;
    pthread_mutex_t lock;
    pthread_cond_t  cond;
} jsqueue;

struct T {
    jsqueue *que;
};


//todo: reimplement without any alloc or free calls

//blocking pop
static q_entry *_que_pop(jsqueue *que, long timeout) {
    //todo: respect timeout

    q_entry *item;

    pthread_mutex_lock(&que->lock);
    while (NULL == que->head) {
        pthread_cond_wait(&que->cond, &que->lock);
    }
    item = que->head;
    que->head = item->next;
    if (NULL == que->head) {
        que->tail = NULL;
    }
    pthread_mutex_unlock(&que->lock);

    return item;
}

static void _que_push(T _this_, q_entry *item) {

    assert(item);

    jsqueue *que = _this_->que;

    item->next = NULL;

    pthread_mutex_lock(&que->lock);

    if (NULL == que->tail) {
        que->head = item;
    } else {
        que->tail->next = item;
    }
    que->tail = item;

    pthread_cond_signal(&que->cond);
    pthread_mutex_unlock(&que->lock);
}

T JacksEventQueue_new() {
    T _this_ = malloc(sizeof *_this_);
    if (_this_ == NULL) {
        fprintf (stderr, "JacksEventQueue_new: can not alloc event\n");
        return NULL;
    }

    jsqueue *que;
    que = calloc(1, sizeof *que);
    pthread_mutex_init(&que->lock, NULL);
    pthread_cond_init(&que->cond, NULL);
    _this_->que = que;

    return _this_;
}

void JacksEventQueue_free( T *_this_p_ ) {
    assert(_this_p_ && *_this_p_);
    T _this_ = *_this_p_;
    jsqueue *que = _this_->que;
    pthread_mutex_destroy( &que->lock );
    pthread_cond_destroy( &que->cond );
    free(que);
    free(_this_);
}

void JacksEventQueue_put( T _this_, JacksEvent jsevent) {

    q_entry *item = malloc(sizeof *item);

    item->jsevent = jsevent;

    _que_push(_this_, item);
}

JacksEvent JacksEventQueue_get( T _this_, long timeout ) {

    JacksEvent ret;

    for (;;) { 

        q_entry *item = _que_pop(_this_->que, timeout);
        //todo: respect timeout here

        if (item == NULL) continue;

        ret = item->jsevent;

        free(item);

        break;
    }
    return ret;
}

#undef T

