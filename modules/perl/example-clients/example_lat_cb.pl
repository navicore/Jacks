#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use AnyEvent;
use AnyEvent::Strict;

my $jc;

$jc = jacks::JsClient->new("watch latency", undef, $jacks::JackNullOption, 0);

my $pplist =  $jc->getPortNames("play");
my $pname = $pplist->get(0);
my $pport = $jc->getPort($pname);

$pport->initLatencyListener();

my $status = "none";
my $status_ready = AnyEvent->condvar;
# POSIX signal
my $x = AnyEvent->signal (signal => "USR2", cb => sub { 
    $status = "recompute needed";
    $status_ready->send;
});

$status_ready->recv;
print("done. status: $status\n");

