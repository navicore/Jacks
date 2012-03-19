#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use Test::More tests => 204;
my $iter = 100;

my $one = 1;
ok($one, "should be won");

my $freq            = 880;
my $max_amp         = 0.5;
my $dur_arg         = 100;
my $attack_percent  = 1;
my $decay_percent   = 10;
my $transport_aware = 0;
my $got_bpm         = 300;
my $client_name     = "metro_perl_unittest";
my $PI              = 3.14;
my $offset          = 0;

my $transport_state;

my @wave;
my @amp;

my $jc = jacks::JsClient->new($client_name, undef, $jacks::JackNullOption);
ok($jc, "no client");
my $out = $jc->registerPort("output", $jacks::JackPortIsOutput);
$jc->activate();

my $speaker = $jc->getPortByType("sys", "", $jacks::JackPortIsPhysical|$jacks::JackPortIsInput, 0);
ok($speaker);
my $rc = $out->connect($speaker);
ok($rc == 0);

#
# setup wave table parameters
#
my $wave_length     = 60 * $jc->getSampleRate() / $got_bpm;
my $tone_length     = $jc->getSampleRate() * $dur_arg / 1000;
my $attack_length   = $tone_length * $attack_percent / 100;
my $decay_length    = $tone_length * $decay_percent / 100;
my $scale           = 2 * $PI * $freq / $jc->getSampleRate();

print("wave_length: $wave_length tone_length: $tone_length attack_length: $attack_length decay_length: $decay_length scale: $scale\n");

if ($tone_length >= $wave_length) {
	die("invalid tone_length / wave_length\n");
}
if ($attack_length + $decay_length > $tone_length) {
	die("invalid attack_length / decay_length / tone_length\n");
}

#
# Build the wave table
#
for (my $i = 0; $i < $attack_length; $i++) {
    $amp[$i] = $max_amp * $i / $attack_length;
}
for (my $i = $attack_length; $i < $tone_length - $decay_length; $i++) {
		$amp[$i] = $max_amp;
}
for (my $i = $tone_length - $decay_length; $i < $tone_length; $i++) {
		$amp[$i] = - $max_amp * ($i - $tone_length) / $decay_length;
}
for (my $i = 0; $i < $tone_length; $i++) {
		$wave[$i] = $amp[$i] * sin($scale * $i);
}
for (my $i = $tone_length; $i < $wave_length; $i++) {
    $wave[$i] = 0;
}

for (my $i=0; $i< $iter; $i++) {

    my $jsevent = $jc->getEvent(-1);
    ok($jsevent);

    if ($jsevent->getType() == $jacks::PROCESS) {

        process_audio();
        #dump_audio();

    } elsif ($jsevent->getType() == $jacks::SAMPLE_RATE_CHANGE) {
        my $sr = $jc->getSampleRate();
        print("sample rate is now $sr\n");

    } else {
        print("what was that?\n");
    }

    $jsevent->complete();
}

ok("done!");

sub dump_audio {
    my $sample = $out->getBuffer();
    my $nframes = $sample->getNFrames();
    my $len = 10;
    my $s = $sample->toHexString($nframes - $len, $len, "\n");
    print("out sample hex:\n$s\n");
}

sub process_audio {

    my $outbuffer = $out->getBuffer();
    my $nframes = $outbuffer->length();
    my $frames_left = $nframes;
    ok("sound!");
		
	while ($wave_length - $offset < $frames_left) {
        for (my $i = 0; $i < ($wave_length - $offset); $i++) {
            #jacks::sample_set($outbuffer,$nframes - $frames_left + $i,$wave[$offset + $i]);
            $outbuffer->setf($nframes - $frames_left + $i,$wave[$offset + $i]);
        }
		$frames_left -= $wave_length - $offset;
		$offset = 0;
	}
	if ($frames_left > 0) {
        for (my $i = 0; $i < $frames_left; $i++) {
            #jacks::sample_set($outbuffer,$nframes - $frames_left + $i,$wave[$offset + $i]);
            $outbuffer->setf($nframes - $frames_left + $i,$wave[$offset + $i]);
        }
		$offset += $frames_left;
	}
}

