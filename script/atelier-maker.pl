use strict;
use warnings;

use Atelier::Builder;
use Getopt::Long;
use Pod::Usage;

GetOptions(
    flavor => \my $flavor,
);
my $app_name = shift(@ARGV) or pod2usage(0);

Atelier::Builder->new(
    flavor   => $flavor || 'Basic',
    app_name => $app_name,
)->build;

=pod
=cut
