use strict;
use warnings;

use Atelier::FlavorMaker;
use Getopt::Long;
use Pod::Usage;

GetOptions(
    'flavor=s'   => \my $flavor_name,
    'dir=s'      => \my $dir,
    'app_name=s' => \my $app_name,
);
$dir ||= '.';

print Atelier::FlavorMaker->new(
    name     => $flavor_name,
    dir      => $dir,
    app_name => $app_name,
)->create;

=pod
    atelier-flavormaker.pl --flaver=FlaverName [--dir=./dir]
=cut
