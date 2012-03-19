#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'jacks' ) || print "Bail out!
";
}

#diag( "Testing jacks $jacks::VERSION, Perl $], $^X" );
