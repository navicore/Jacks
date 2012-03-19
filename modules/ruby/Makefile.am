SUBDIRS = . test example-clients

include_HEADERS = 

EXTRA_DIST = 

rubydir = ${bindir}
ruby_DATA = 

_cflags = -I$(top_builddir)/corelib @OE_LIB_CFLAGS@ @RUBY_CPPFLAGS@
_libadd = $(top_builddir)/corelib/libjacks.la @RUBY_LDFLAGS@ @RUBY_EXTRA_LIBS@

lib_LTLIBRARIES = libjacks_ruby.la 

_libjacks_ruby_la_SOURCES = Jacks_ruby_wrap.c

libjacks_ruby_la_SOURCES = ${_libjacks_ruby_la_SOURCES}

libjacks_ruby_la_LIBADD = ${_libadd}
libjacks_ruby_la_CFLAGS = ${_cflags}
libjacks_ruby_la_LDFLAGS = @OE_LIB_LDFLAGS@

swig:
	swig -I${top_builddir}/corelib -Wall -ruby -o ./Jacks_ruby_wrap.c ../Jacks.i

