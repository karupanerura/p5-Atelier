#!/usr/bin/env perl
use strict;
use warnings;

use Atelier::FlavorMaker;
use Getopt::Long;
use Pod::Usage;

GetOptions(
    'flavor=s'   => \my $flavor_name,
    'dir=s'      => \my $dir,
    'app_name=s' => \my $app_name,
    'version=s'  => \my $version,
);
pod2usage(0) if($help);
$dir ||= '.';

print Atelier::FlavorMaker->new(
    name     => $flavor_name,
    dir      => $dir,
    app_name => $app_name,
    version  => $version,
)->create;

__END__

=head1 NAME

atelier-flavormaker.pl - setup flavor for Atelier from some Atelier application.

=head1 SYNOPSIS

  % atelier-flavormaker.pl --flavor=Foo --app_name=AppName --dir=AppDir --version=0.01 > ~/perl5/lib/perl5/Atelier/Flavor/Foo.pm

        --flavor=Foo          Flavor name
        --app_name=AppName    Base application's name
        --dir=AppDir          Base application's directory
        --version=0.01        Flavor version

        --help          Show this help

=head1 DESCRIPTION

This is setup flavor for Atelier from some Atelier application.

atelier-flavormaker.pl can build flavor from Atelier application.
You can make your own flavor.

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

L<atelier-builder.pl>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
