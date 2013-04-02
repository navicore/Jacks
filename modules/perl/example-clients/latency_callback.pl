#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use AnyEvent;
use AnyEvent::Strict;

my $jc;

$jc = jacks::JsClient->new("watch latency", undef, $jacks::JackNullOption, 0);

my $pplist =  $jc->getPortNames("play");
my $cplist =  $jc->getPortNames("cap");
my $pname = $pplist->get(0);
my $cname = $cplist->get(0);
my $pport = $jc->getPort($pname);
my $cport = $jc->getPort($cname);
my $platency = $pport->getLatencyRange($jacks::JackPlaybackLatency);
my $pmin = $platency->min();
my $pmax = $platency->max();
print("pport latency [ $pmin $pmax ]\n");
my $clatency = $cport->getLatencyRange($jacks::JackCaptureLatency);
my $cmin = $clatency->min();
my $cmax = $clatency->max();
print("cport latency [ $cmin $cmax ]\n");

#my $pfd = $pport->initLatencyListener();
$pport->initLatencyListener();

my $status = "none";
my $status_ready = AnyEvent->condvar;
# POSIX signal
my $x = AnyEvent->signal (signal => "USR2", cb => sub { 
    $status = "recompute needed";
    $status_ready->send;
});

$pport->wakeup();
$status_ready->recv;
print("done. status: $status\n");

