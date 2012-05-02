#!/usr/bin/perl
use jacks;
use strict;
use warnings;

my $jc;

$jc = jacks::JsClient->new("watch latency", undef, $jacks::JackNullOption, 0);

my $plist =  $jc->getPortNamesByType("sys", 
                                     undef,
                                     $jacks::JackPortIsInput | $jacks::JackPortIsPhysical);

print("\n--- input physical ports ---\n");
print_latency($plist);

$plist =  $jc->getPortNamesByType("sys", undef, $jacks::JackPortIsOutput);

print("\n--- output ports ---\n");
print_latency($plist);

sub print_latency {
    my $plist = shift @_;
    for (my $i = 0; $i < $plist->length(); $i++) {
        my $pname = $plist->get($i);
        print("$pname\n");
        my $port = $jc->getPort($pname);

        my $platency = $port->getLatencyRange($jacks::JackPlaybackLatency);
        my $pmin = $platency->min();
        my $pmax = $platency->max();
        print("\t\tPlayback Latency [ $pmin $pmax ]\n");

        my $clatency = $port->getLatencyRange($jacks::JackCaptureLatency);
        my $cmin = $clatency->min();
        my $cmax = $clatency->max();
        print("\t\tCapture Latency [ $cmin $cmax ]\n");
    }
}

#
# also
#
# set latencies example:
# $port->setLatencyRange($jacks::JackCaptureLatency, 64, 128);
#
# recompute latencies:
# $jc->recomputeLatencies();
#

