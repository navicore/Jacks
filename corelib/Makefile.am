SUBDIRS = . test

docdir = $(datadir)/doc/
doc_DATA = 

noinst_LTLIBRARIES = libjacks.la


MYSOURCES = JacksRbClient.c JacksClient.c JacksHelper.c JacksLatch.c JacksEvent.c JacksEventQueue.c JacksPort.c JacksRbPort.c

include_HEADERS = Jacks.h JacksEventQueue.h JacksRbClient.h JacksClient.h JacksLatch.h JacksEvent.h JacksPort.h JacksRbPort.c

libjacks_la_SOURCES = ${MYSOURCES}
libjacks_la_LIBADD = @JACK_LIBS@
libjacks_la_CFLAGS = @JACK_CFLAGS@
libjacks_la_LDFLAGS = -lpthread

