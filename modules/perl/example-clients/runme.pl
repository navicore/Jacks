#!/usr/bin/perl
use strict;
use warnings;
use AnyEvent;

# POSIX signal
#my $x = AnyEvent->signal (signal => "USR2", cb => sub { 
#    print("ejs got some usr sig\n");
#    die("ejs got some usr sig\n");
#});

my $t = AnyEvent->timer( after => 0, interval => 1, cb => sub {
        open (MYFILE, '>>/tmp/data.txt');
        print "Hello\n";
        print MYFILE "Hello\n";
        close (MYFILE); 
        });

sleep 5;
print("ejs done?\n");

