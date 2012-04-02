#!/usr/bin/perl
use jacks;
use strict;
use warnings;
use Math::Trig;
use Test::More tests => 1;

my $jc = jacks::JsClient->new("test", undef, $jacks::JackNullOption, 0);
ok($jc, "got client");

