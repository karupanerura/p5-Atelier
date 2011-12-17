package Atelier::Plugin::Config::Perl;
use strict;
use warnings;
use utf8;

use Atelier::Plugin::Config -base;

use Carp ();
use File::Spec;

sub load_config {
    my $self = shift;

    my $base_dir    = $self->base_dir;
    my $config_mode = $self->get_config_mode;
    my $config_file_name = File::Spec->catfile($base_dir, 'config', "${config_mode}.pl");

    my $hash = do("$config_file_name");
    Carp::croak("Cannot load configuration file: '${config_file_name}'. Error: $@") if $@;
    Carp::croak("Cannot load configuration file: '${config_file_name}'. Error: $!") unless defined $hash;
    unless (ref($hash) eq 'HASH') {
        Carp::croak("'${config_file_name}' does not return HashRef.");
    }

    return $hash;
}

1;
