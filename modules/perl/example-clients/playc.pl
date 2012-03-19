#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use Math::Trig;

my $jc = jacks::JsClient->new("playc", $jacks::JackNullOption);
my $out = $jc->registerPort("outee", $jacks::JackPortIsOutput);
$jc->activate();

#my $speaker = $jc->getPortByName("system:playback_1");
my $speaker = $jc->getPortByType("sys", "", 
$jacks::JackPortIsPhysical|$jacks::JackPortIsInput, 0);

if ($speaker == 0) {
    die("no output ports\n");
}
$out->connect($speaker);

my @cycle;
my $offset = 0;
my $tone = 262;

my $samincy = $jc->getSampleRate / $tone;
my $scale = 2 * pi / $samincy;
for(my $i = 0; $i < $samincy; $i++){
    $cycle[$i]=sin($i * $scale);
}

for (;;) {

    my $jsevent = $jc->getEvent(-1);
    if ($jsevent->getType() == $jacks::PROCESS) {
        my $outbuffer = $out->getBuffer();

        my $nframes = $outbuffer->length();
        for (my $i = 0; $i < $nframes; $i++) {
          $outbuffer->setf($i,$cycle[$offset]);
          $offset++;
          if ($offset > $samincy) { $offset = 0 };
        }
    } elsif ($jsevent->getType() == $jacks::SAMPLE_RATE_CHANGE) {
        my $sr = $jc->getSampleRate();
        print("sample rate is now $sr\n");
    } else {
        print("what was that?\n");
    }
    $jsevent->complete();

}

