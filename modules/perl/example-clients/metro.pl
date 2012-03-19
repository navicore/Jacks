#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use Math::Trig;

my $connect;
my $output;
my $help;
my $freq            = 880;
my $max_amp         = 0.5;
my $dur_arg         = 100;
my $attack_percent  = 1;
my $decay_percent   = 10;
my $transport_aware = 0;
my $got_bpm         = 0;
my $client_name     = "metro";
my $PI              = 3.14;
my $offset          = 0;

my $transport_state;

my @wave;
my @amp;

init();

if (!$got_bpm) {
    usage ();
	die("bpm not specified\n");
}

my $jc = jacks::JsClient->new($client_name, undef, $jacks::JackNullOption);
my $out = $jc->registerPort("output", $jacks::JackPortIsOutput);
$jc->activate();

if ($connect || $output) {
    my $speaker;
    if ($output) {
        $speaker = $jc->getPortByName($output);
    } else {
        $speaker = $jc->getPortByType("sys", "", $jacks::JackPortIsPhysical|$jacks::JackPortIsInput, 0);
    }
    if ($speaker == 0) {
        die("no output ports\n");
    }
    $out->connect($speaker);
}

#
# setup wave table parameters
#
my $wave_length     = 60 * $jc->getSampleRate() / $got_bpm;
my $tone_length     = $jc->getSampleRate() * $dur_arg / 1000;
my $attack_length   = $tone_length * $attack_percent / 100;
my $decay_length    = $tone_length * $decay_percent / 100;
my $scale           = 2 * $PI * $freq / $jc->getSampleRate();

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

for (;;) {

    my $jsevent = $jc->getEvent(-1);

    if ($jsevent->getType() == $jacks::PROCESS) {

        #todo: transport_aware calls process_silence

        process_audio();

    } elsif ($jsevent->getType() == $jacks::SAMPLE_RATE_CHANGE) {
        my $sr = $jc->getSampleRate();
        print("sample rate is now $sr\n");

    } else {
        print("what was that?\n");
    }

    $jsevent->complete();
}

sub process_silence {

    my $outbuffer = $jc->getOutBuffer();
    my $nframes = $jc->getNFrames();
    for (my $i = 0; $i < $nframes; $i++) {
        jacks::sample_set($outbuffer, $i, 0);
    }
}

sub process_audio {

    my $outbuffer = $out->getBuffer();
    my $nframes = $outbuffer->length();
    my $frames_left = $nframes;
		
	while ($wave_length - $offset < $frames_left) {
        for (my $i = 0; $i < ($wave_length - $offset); $i++) {
            $outbuffer->setf($nframes - $frames_left + $i,$wave[$offset + $i]);
        }
		$frames_left -= $wave_length - $offset;
		$offset = 0;
	}
	if ($frames_left > 0) {
        for (my $i = 0; $i < $frames_left; $i++) {
            $outbuffer->setf($nframes - $frames_left + $i,$wave[$offset + $i]);
        }
		$offset += $frames_left;
	}
}

sub usage {
    print STDERR << "EOF";

    This program beeps.

    usage: $0 [-f n] [-A n] [-D n] [-a %] [-d %] [-n s] [-t b] [-b n]

     --connect      : find an outpot port and connect to it
     --frequency n  : freq (in Hz)
     --Amplitude n  : amplitude (between 0 and 1)
     --Duration n   : duration (in ms)
     --attack %     : attach (in % of duration)
     --decay %      : decay (in % of duration)
     --name s       : jack name of metronome client
     --transport b  : transport aware
     --bpm n        : beats per minute
     --help         : this message

    example: $0 -b 300 -n mymetronome

EOF
}

#
# Command line options processing
#
sub init {
    use Getopt::Long;
    GetOptions (
    'connect' => \$connect,
    'output=s' => \$output,
    'freq=f' => \$freq,
    'amplitude=f' => \$max_amp,
    'attack=f' => \$attack_percent,
    'duration=i' => \$dur_arg,
    'decay=f' => \$decay_percent,
    'bpm=n' => \$got_bpm,
    'name=s' => \$client_name,
    'transport=i' => \$transport_aware,
    'help|?' => \$help,
    ) or usage();

    if ( $help ) {
        usage();
        exit();
	}
}

