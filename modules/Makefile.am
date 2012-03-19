SUBDIRS = @OE_LIST_OF_SCRIPTING_APIS_TO_BUILD@

include_HEADERS =

EXTRA_DIST = 

swigdir = ${bindir}
swig_DATA = 

swig:
	make -C perl swig
	make -C lua swig
	make -C python2 swig
	make -C python3 swig
	make -C ruby swig

