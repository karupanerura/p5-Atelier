use strict;
use Test::More;
use File::Find;

my @mod;
find(\&wanted, 'lib');

plan tests => scalar @mod;
require_ok $_ for @mod;

sub wanted {
    if (/\.pm$/) {
        my $module = $File::Find::name;
        $module =~ s@^lib/(.*)\.pm$@$1@;
        $module =~ s@/@::@g;
        push @mod, $module;
    }
}
