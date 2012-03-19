#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use Math::Trig;
use Test::More tests => 1;

my $jc = jacks::JsClient->new("test", undef, $jacks::JackNullOption);
ok($jc, "got client");

