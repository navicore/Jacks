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

#ifndef JSEVENTQ_H
#define JSEVENTQ_H

#include "config.h"
#include "JacksEvent.h"
#include "JacksEventQueue.h"
#include <assert.h>

#define T JacksEventQueue
typedef struct T *T;

extern T       JacksEventQueue_new();

extern void    JacksEventQueue_free( T * );

extern void    JacksEventQueue_put( T, JacksEvent);

extern JacksEvent JacksEventQueue_get( T, long );

#undef T
#endif

