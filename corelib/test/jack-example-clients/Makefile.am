SUBDIRS = .

EXTRA_DIST=

oe_ldadd = @JACK_LIBS@
oe_cflags = @OE_LIB_CFLAGS@ @OE_TESTER_CFLAGS@

include_HEADERS = 

bin_PROGRAMS = capture_client metro simple_client

capture_client_SOURCES = capture_client.c
capture_client_LDADD = ${oe_ldadd} -lsndfile
capture_client_CFLAGS = ${oe_cflags}
capture_client_LDFLAGS = @OE_TESTER_LDFLAGS@

metro_SOURCES = metro.c
metro_LDADD = ${oe_ldadd}
metro_CFLAGS = ${oe_cflags}
metro_LDFLAGS = @OE_TESTER_LDFLAGS@

simple_client_SOURCES = simple_client.c
simple_client_LDADD = ${oe_ldadd} -lsndfile
simple_client_CFLAGS = ${oe_cflags}
simple_client_LDFLAGS = @OE_TESTER_LDFLAGS@

TESTS = 

all-local:
	mkdir -p data

clean-local:
	rm -rf data

