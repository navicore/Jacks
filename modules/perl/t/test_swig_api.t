#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use Test::More tests => 7;
my $iter = 100;

my $jc = jacks::JsClient->new("myclient", undef, $jacks::JackNullOption, 0);
ok($jc, "no client");

my $capture_port = $jc->getPortByName("system:capture_1");
ok($capture_port);

my $plist =  $jc->getPortNames("sys");
ok($plist);
my $port1 = $jc->getPort($plist->get(0));
ok($port1);
my $r = $port1->getLatencyRange($jacks::JackCaptureLatency);
ok($r);

for (my $i=0; $i< $iter; $i++) {

    my $jsevent = $jc->getEvent(-1);
    ok($jsevent);

    if ($jsevent->getType() == $jacks::PROCESS) {

        #process_audio();
        #dump_audio();

    } elsif ($jsevent->getType() == $jacks::SAMPLE_RATE_CHANGE) {
        my $sr = $jc->getSampleRate();
        print("sample rate is now $sr\n");
        $i = $iter; #quick test

    } else {
        print("what was that?\n");
    }

    $jsevent->complete();
}

ok("done!");

