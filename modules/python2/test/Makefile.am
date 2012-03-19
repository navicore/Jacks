check_PROGRAMS = 

EXTRA_DIST = script_runner test_swig_api.py

include_HEADERS = 

TESTS = script_runner

all-local:
	cp ../jacks.py .
	ln -f -s ../.libs/libjacks_python.so ./_jacks.so

clean-local:
	rm -f ./jacks.py
	rm -f ./jacks.pyc
	rm -f ./_jacks.so
	rm -f ./*.pyc

