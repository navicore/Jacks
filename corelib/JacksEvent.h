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

#ifndef JSEVENT_H
#define JSEVENT_H

#include "config.h"
#include <assert.h>

#define T JacksEvent
typedef struct T *T;

typedef int JSEVENT_CTOKEN (void *);

extern T JacksEvent_new(int, JSEVENT_CTOKEN *, void *);

extern void JacksEvent_complete(T);

extern int JacksEvent_get_type(T _this_);

extern void *JacksEvent_get_data(T _this_);
extern void JacksEvent_set_data(T, void *);
extern void JacksEvent_free(T *);

#undef T
#endif

