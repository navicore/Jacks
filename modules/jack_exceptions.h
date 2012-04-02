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

#ifndef JACKPEXCEPTIONS_H
#define JACKPEXCEPTIONS_H

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

#endif

