use strict;
use Test::More;
use Module::Find qw/findallmod/;

my @mod =
    grep { not m{^Atelier::Dispatcher::RouterSimple} }
    grep { not m{^Atelier::Plugin} }
    ('Atelier', findallmod('Atelier'));
plan tests => scalar @mod;
require_ok $_ for @mod;
