#!/usr/bin/perl
use feature qw(switch);
use jacks;
use strict;
use warnings;
use AnyEvent;
use AnyEvent::Strict;
use AnyEvent::Handle;

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

my $pfd = $pport->initPlaybackLatencyListener();

my $status = "none";
my $status_ready = AnyEvent->condvar;
# fd signal
my $x = AnyEvent->io (fh => $pfd, poll=>"r", cb => sub {
        #my $m = <$pfd>;
        #given($m) {
        #    when (0)  {$status = "zero";}
        #    when (1)  {$status = "one";}
        #    default  {$status = "what? $m";}
        #}
        #TODO use AnyEvent::Handle
        $status = "what?";
        $status_ready->send;
});

$pport->wakeupLatencyCallbacks();
$status_ready->recv;
print("done. status1: $status\n");

#$pport->wakeupFd();
$status_ready->recv;
print("done. status2: $status\n");

#$pport->wakeupFd();
$status_ready->recv;
print("done. status3: $status\n");

