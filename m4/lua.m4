dnl created by modifying original found at 
dnl https://svn.i-want-a-pony.com/repos/wombat/trunk/build/ac-macros/lua.m4
dnl the original project uses the apache 2.0 license even though this file
dnl didn't say so.
dnl
dnl Check to see if this build should compile lua or just create a shared lib
dnl CHECK_OE_LUA(ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND])
dnl Sets:
dnl  LUA_CFLAGS
dnl  LUA_LIBS
dnl  AM_CONDITIONAL(OE_LUA_SHARED_LIB_ONLY, ?)

AC_DEFUN([CHECK_OE_LUA],
[dnl
    defined_lib_only=no
    
    AC_ARG_WITH([lua],
        [  --with-lua              Only build lua shared lib for luarock],
    	[AC_MSG_RESULT([using --with-lua. not installing full utils])
        defined_lib_only=yes]
        )
    
    AC_ARG_ENABLE([oelib-only],
        [  --enable-oelib-only     Only build lua shared lib for luarock],
    	[AC_MSG_RESULT([using --enable-oelib-only. not installing full utils])
        defined_lib_only=yes]
        )
    
    if test x$defined_lib_only = xno ; then
        AM_CONDITIONAL(OE_LUA_SHARED_LIB_ONLY, false)
        AC_DEFINE([LUA_USE_POSIX],[],[lua shell will compile support for posix])
        LUA_LIBS="\$(top_builddir)/modules/scripting/lua/liboelua.la"
        LUA_CFLAGS="-I\$(top_builddir)/modules/scripting/lua"
        AC_SUBST(LUA_LIBS)
        AC_SUBST(LUA_CFLAGS)
        AC_MSG_RESULT([compiling oe lua dist]);
    else
        AM_CONDITIONAL(OE_LUA_SHARED_LIB_ONLY, true)
        AC_MSG_RESULT([*not* compiling oe lua dist. using a lua dist already installed]);
        CHECK_LUA([$1],[$2])
    fi
])

dnl Check for Lua 5.1 Libraries
dnl CHECK_LUA(ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND])
dnl Sets:
dnl  LUA_CFLAGS
dnl  LUA_LIBS

AC_DEFUN([CHECK_LUA],
[dnl

AC_ARG_WITH(
    lua-path,
    [AC_HELP_STRING([--with-lua-path=PATH],[Path to the Lua 5.1 prefix])],
    lua_path="$withval",
    :)

dnl # Determine lua lib directory
if test -z $lua_path; then
    test_paths="/usr/local /opt/local /usr/pkg /usr"
else
    test_paths="${lua_path}"
fi

for x in $test_paths ; do
    AC_MSG_CHECKING([for lua.h in ${x}/include/lua5.1])
    if test -f ${x}/include/lua5.1/lua.h; then
        AC_MSG_RESULT([yes])
        save_CFLAGS=$CFLAGS
        save_LDFLAGS=$LDFLAGS
        CFLAGS="$CFLAGS"
        LDFLAGS="-L$x/lib $LDFLAGS"
        AC_CHECK_LIB(lua5.1, luaL_newstate,
            [
            LUA_LIBS="-L$x/lib -llua5.1"
            LUA_CFLAGS="-I$x/include/lua5.1"
            ])
        CFLAGS=$save_CFLAGS
        LDFLAGS=$save_LDFLAGS
        break
    else
        AC_MSG_RESULT([no])
    fi
    AC_MSG_CHECKING([for lua.h in ${x}/include])
    if test -f ${x}/include/lua.h; then
        AC_MSG_RESULT([yes])
        save_CFLAGS=$CFLAGS
        save_LDFLAGS=$LDFLAGS
        CFLAGS="$CFLAGS"
        LDFLAGS="-L$x/lib $LDFLAGS"
        AC_CHECK_LIB(lua, luaL_newstate,
            [
            LUA_LIBS="-L$x/lib -llua"
            LUA_CFLAGS="-I$x/include"
            ])
        CFLAGS=$save_CFLAGS
        LDFLAGS=$save_LDFLAGS
        break
    else
        AC_MSG_RESULT([no])
    fi
done

AC_SUBST(LUA_LIBS)
AC_SUBST(LUA_CFLAGS)

if test -z "${LUA_LIBS}"; then
  AC_MSG_NOTICE([*** Lua 5.1 library not found.])
  ifelse([$2], , AC_MSG_ERROR([Lua 5.1 library is required]), $2)
else
  AC_MSG_NOTICE([using '${LUA_LIBS}' for Lua Library])
  ifelse([$1], , , $1) 
fi 
])

