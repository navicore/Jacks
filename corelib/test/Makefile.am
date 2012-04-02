SUBDIRS = .

EXTRA_DIST=

oe_ldadd = ${top_srcdir}/corelib/libjacks.la @JACK_LIBS@
oe_cflags = -I$(top_srcdir)/corelib @OE_LIB_CFLAGS@ @OE_TESTER_CFLAGS@

include_HEADERS = 

check_PROGRAMS = test_jackclient

test_jackclient_SOURCES = test_jackclient.c
test_jackclient_LDADD = ${oe_ldadd}
test_jackclient_CFLAGS = ${oe_cflags}
test_jackclient_LDFLAGS = @OE_TESTER_LDFLAGS@

bin_PROGRAMS = floatsize

floatsize_SOURCES = floatsize.c
floatsize_LDADD = ${oe_ldadd}
floatsize_CFLAGS = ${oe_cflags}
floatsize_LDFLAGS = @OE_TESTER_LDFLAGS@

TESTS = test_jackclient

all-local:
	mkdir -p data

clean-local:
	rm -rf data

