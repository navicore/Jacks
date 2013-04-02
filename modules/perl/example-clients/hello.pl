#!/usr/bin/perl
use AnyEvent;

my $status = "none";
print "status is $status\n";
$| = 1; print "enter your name>\n";

my $name;

my $wait_for_input = AnyEvent->io (
      fh   => \*STDIN, # which file handle to check
      poll => "r",     # which event to wait for ("r"ead data)
      cb   => sub {    # what callback to execute
        $name = <STDIN>; # read it
        $status = "recompute";
        #print "yay.  something fucking happend.";
      }
);

sleep 10;

# do something else here
print "name is $name\n";
print "status is $status\n";

