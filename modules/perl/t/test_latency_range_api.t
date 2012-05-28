#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use Test::More tests => 5;

my $jc = jacks::JsClient->new("myclient", undef, $jacks::JackNullOption, 0);

my $port = $jc->getPort("system:capture_1");  #note, not sure if this is universal, if
                                              #your tests fail here, change to valid name

my $orig_range = $port->getLatencyRange($jacks::JackCaptureLatency);
ok($orig_range);

my $newmin = $orig_range->min() + 64;
my $newmax = $orig_range->max() + 64;

$port->setLatencyRange($jacks::JackCaptureLatency, $newmin, $newmax);
my $new_range = $port->getLatencyRange($jacks::JackCaptureLatency);

ok($new_range->max() != $orig_range->max());
ok($new_range->min() != $orig_range->min());
ok($newmin = $new_range->min());
ok($newmax = $new_range->max());

