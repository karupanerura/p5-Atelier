package Atelier::Plugin::Config::Perl;
use strict;
use warnings;

use Atelier::Plugin::Config -base;

require JSON;
use File::Spec;

sub load_config {
    my $self = shift;

    my $base_dir    = $self->base_dir;
    my $config_mode = $self->get_config_mode;
    my $config_file_name = File::Spec->catfile($base_dir, 'config', "${config_mode}.pl");

    do($config_file_name) or die "Cannot load configuration file: $config_file_name";
}

1;
