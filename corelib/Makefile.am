SUBDIRS = lfds . test

docdir = $(datadir)/doc/
doc_DATA = 

noinst_LTLIBRARIES = libjacks.la

MYSOURCES = JacksRbClient.c JacksHelper.c JacksLatch.c JacksEvent.c JacksRbPort.c 

MYHEADERS = Jacks.h JacksRbClient.h JacksLatch.h JacksEvent.h JacksRbPort.h JacksExceptions.h

include_HEADERS = ${MYHEADERS}

libjacks_la_SOURCES = ${MYSOURCES}
libjacks_la_LIBADD = @JACK_LIBS@ -L${top_builddir}/corelib/lfds -ljacks_lfds
libjacks_la_CFLAGS = @JACK_CFLAGS@ -I$(top_builddir)/corelib/lfds
libjacks_la_LDFLAGS = -lpthread

