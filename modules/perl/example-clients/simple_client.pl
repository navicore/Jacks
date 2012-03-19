#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use Cwd 'abs_path';

my $jc;

if (defined($ARGV[0])) {
    print("restarting with uuid $ARGV[0]\n");
    $jc = jacks::JsClient->new("simpler", $ARGV[0], $jacks::JackSessionID);
} else {
    $jc = jacks::JsClient->new("simpler", undef, $jacks::JackNullOption);
}


my $in = $jc->registerPort("input", $jacks::JackPortIsInput);

my $out = $jc->registerPort("output", $jacks::JackPortIsOutput);

$jc->activate();

my $done = undef;
until($done) {

    my $jsevent = $jc->getEvent(-1);

    if ($jsevent->getType() == $jacks::PROCESS) {

        my $inbuffer = $in->getBuffer();

        my $outbuffer = $out->getBuffer();

        my $nframes = $outbuffer->length();

        for (my $i = 0; $i < $nframes; $i++) { #copy input to putput

          my $s = $inbuffer->getf($i);

          $outbuffer->setf($i,$s);

        }

    } elsif ($jsevent->getType() == $jacks::SAMPLE_RATE_CHANGE) {

        my $sr = $jc->getSampleRate();
        print("sample rate change event: sample rate is now $sr\n");

    } elsif ($jsevent->getType() == $jacks::SHUTDOWN) {

        print("jack shutdown event\n");
        $done = "done!";

    } elsif ($jsevent->getType() == $jacks::SESSION) {

        my $dir       = $jsevent->getSessionDir();
        my $uuid      = $jsevent->getUuid();
        my $se_type   = $jsevent->getSessionEventType();
        my $setypeTxt = $se_type == $jacks::JackSessionSave ? "save" : "quit";

        print("session notification: path $dir, uuid $uuid, type: $setypeTxt\n");

        if ($se_type == $jacks::JackSessionSaveAndQuit) {
            $done = "done!";
        }

        my $script_path = abs_path($0);
        my $cmd = "perl $script_path $uuid"; 
        $jsevent->setCommandLine($cmd); #tell jackd how to restart us

    } else {
        die("unknown event type\n");
    }

    $jsevent->complete();
}

print("simple_client.pl ended\n");

