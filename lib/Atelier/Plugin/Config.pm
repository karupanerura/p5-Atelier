package Atelier::Plugin::Config;
use strict;
use warnings;

use Atelier::Plugin -base;

sub get_config_mode { $ENV{PLACK_ENV} or 'development' }

{
    my $config;
    sub config {
        my $self = shift;

        $config ||= $self->load_config;
    }
}

1;
