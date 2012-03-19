check_PROGRAMS = 

EXTRA_DIST = script_runner test_swig_api.rb

include_HEADERS = 

TESTS = script_runner

all-local:
	ln -f -s ../.libs/libjacks_ruby@OE_SHSUF@ ./jacks@OE_SHSUF@
	mkdir -p data

clean-local:
	rm -f ./jacks@OE_SHSUF@
	rm -rf ./data

