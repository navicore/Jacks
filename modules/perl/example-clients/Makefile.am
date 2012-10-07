check_PROGRAMS = 

EXTRA_DIST = capture_client.pl script_runner

include_HEADERS = 

TESTS = script_runner

all-local:
	cp ../jacks.pm .
	ln -f -s ../.libs/libjacks_perl.so ./jacks.so

clean-local:
	rm -f ./jacks.pm
	rm -f ./jacks.so

