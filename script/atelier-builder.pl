#!/usr/bin/env perl
use strict;
use warnings;

use Atelier::Builder;
use Getopt::Long;
use Pod::Usage;

GetOptions(
    'flavor=s' => \my $flavor,
    '--help'   => \my $help,
);
pod2usage(0) if($help);
my $app_name = shift(@ARGV) or pod2usage(0);

Atelier::Builder->run(
    $flavor ? (flavor   => $flavor) : (),
    app_name => $app_name,
);

__END__

=head1 NAME

atelier-builder.pl - setup script for Atelier.

=head1 SYNOPSIS

  % atelier-builder.pl MyApp

        --flavor=Basic   basic flavour(default)
        --flavor=Minimum minimalistic flavour

        --help   Show this help

=head1 DESCRIPTION

This is a setup script for Atelier.

atelier-builder.pl can build Atelier application from flavor.
You can write your own flavor.

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

L<atelier-flavormaker.pl>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
