check_PROGRAMS = 

EXTRA_DIST = script_runner test_swig_api.lua

include_HEADERS = 

TESTS = script_runner

all-local:
	ln -f -s ../.libs/libjacks_lua.so ./jacks.so
	ln -f -s ../.libs/libjackssndfile_lua.so ./sndfile.so

clean-local:
	rm -f ./jacks.so
	rm -f ./sndfile.so

