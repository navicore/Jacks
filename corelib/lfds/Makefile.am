SUBDIRS = 

docdir = $(datadir)/doc/
doc_DATA = 

noinst_LTLIBRARIES = libjacks_lfds.la

_LIBLFDSSOURCES = queue_delete.c queue_new.c queue_query.c queue_queue.c freelist_delete.c freelist_pop_push.c freelist_get_and_set.c freelist_new.c freelist_query.c abstraction_aligned_free.c abstraction_aligned_malloc.c abstraction_cas.c abstraction_dcas.c abstraction_increment.c abstraction_internal.h

_LIBLFDSHEADERS = queue_internal.h liblfds.h freelist_internal.h liblfds_internal.h

include_HEADERS = ${MYHEADERS} ${_LIBLFDSHEADERS}

libjacks_lfds_la_SOURCES = ${_LIBLFDSSOURCES}
libjacks_lfds_la_LIBADD = 
libjacks_lfds_la_CFLAGS = @JACK_CFLAGS@
libjacks_lfds_la_LDFLAGS = -lpthread

