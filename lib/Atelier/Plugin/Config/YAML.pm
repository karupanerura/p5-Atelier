package Atelier::Plugin::Config::YAML;
use strict;
use warnings;

use parent qw/Atelier::Plugin::Config/;

require YAML::Syck;
use File::Spec;

sub load_config {
    my $self = shift;

    my $base_dir    = $self->base_dir;
    my $config_mode = $self->get_config_mode;

    YAML::Syck::LoadFile(File::Spec->catfile($base_dir, 'config', "${config_mode}.yaml"));
}

1;
