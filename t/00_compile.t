use strict;
use Test::More;
use Module::Find qw/findallmod/;

my @mod = ('Atelier', findallmod('Atelier'));
plan tests => scalar @mod;
require_ok $_ for @mod;
