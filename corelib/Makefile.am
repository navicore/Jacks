SUBDIRS = . test

docdir = $(datadir)/doc/
doc_DATA = 

noinst_LTLIBRARIES = libjacks.la

#ejs todo: move liblfds to subdir

MYSOURCES = JacksRbClient.c JacksClient.c JacksHelper.c JacksLatch.c JacksEvent.c JacksEventQueue.c JacksPort.c JacksRbPort.c 

MYHEADERS = Jacks.h JacksEventQueue.h JacksRbClient.h JacksClient.h JacksLatch.h JacksEvent.h JacksPort.h JacksRbPort.h

_LIBLFDSSOURCES = queue_delete.c queue_new.c queue_query.c queue_queue.c freelist_delete.c freelist_pop_push.c freelist_get_and_set.c freelist_new.c freelist_query.c abstraction_aligned_free.c abstraction_aligned_malloc.c abstraction_cas.c abstraction_dcas.c abstraction_increment.c abstraction_internal.h

_LIBLFDSHEADERS = queue_internal.h liblfds.h freelist_internal.h 

include_HEADERS = ${MYHEADERS} ${_LIBLFDSHEADERS}

libjacks_la_SOURCES = ${MYSOURCES} ${_LIBLFDSSOURCES}
libjacks_la_LIBADD = @JACK_LIBS@
libjacks_la_CFLAGS = @JACK_CFLAGS@
libjacks_la_LDFLAGS = -lpthread

