SUBDIRS = . test example-clients

include_HEADERS = 

EXTRA_DIST = 

luadir = ${bindir}
lua_DATA = 

_cflags = -I$(top_builddir)/corelib @LUA_CFLAGS@ @OE_LIB_CFLAGS@ @JACK_LIBS@
_libadd = $(top_builddir)/corelib/libjacks.la @LUA_LIBS@

_libjacks_lua_la_SOURCES = Jacks_lua_wrap.c

libjacks_lua_la_SOURCES = ${_libjacks_lua_la_SOURCES}

lib_LTLIBRARIES = libjacks_lua.la 

libjacks_lua_la_LIBADD = ${_libadd}
libjacks_lua_la_CFLAGS = ${_cflags}
libjacks_lua_la_LDFLAGS = @OE_LIB_LDFLAGS@ -module 

swig:
	swig -I${top_builddir}/corelib -Wall -lua -o ./Jacks_lua_wrap.c ../Jacks.i

luaapiscriptdir = ${datarootdir}/lua/bin

install-data-hook:
	mkdir -p ${luaapiscriptdir}
	ln -f -s ${libdir}/libjacks_lua.so ${luaapiscriptdir}/jacksimpl.so

