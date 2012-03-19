SUBDIRS = . test example-clients

include_HEADERS = 

EXTRA_DIST = jacks.py Documentation.txt setup.py.in

pythondir = ${bindir}
python_DATA = 

_cflags = -I$(top_builddir)/corelib @OE_LIB_CFLAGS@ @PYTHON_CPPFLAGS@
_libadd = $(top_builddir)/corelib/libjacks.la @PYTHON_LDFLAGS@ @PYTHON_EXTRA_LDFLAGS@ @PYTHON_EXTRA_LIBS@

lib_LTLIBRARIES = libjacks_python.la 

libjacks_python_la_SOURCES = Jacks_python3_wrap.c

libjacks_python_la_LIBADD = ${_libadd}
libjacks_python_la_CFLAGS = ${_cflags}
libjacks_python_la_LDFLAGS = @OE_LIB_LDFLAGS@ -module

all:
	mkdir -p build/lib
	cp ./.libs/libjacks_python.so ./build/lib/_jacks.so

clean-local:
	rm -rf ./build

check:

install-data-hook:
if OE_INSTALL_PYTHON_MODULE
	cp ./.libs/libjacks_python.so ./_jacks.so
	cp ./jacks.py .
	python setup.py install
endif

swig:
	swig -I${top_builddir}/corelib -Wall -python -o ./Jacks_python3_wrap.c ../Jacks.i

