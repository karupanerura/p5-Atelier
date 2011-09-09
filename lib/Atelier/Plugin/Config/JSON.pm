package Atelier::Plugin::Config::JSON;
use strict;
use warnings;

use Atelier::Plugin::Config -base;

require JSON;
use File::Spec;

sub load_config {
    my $self = shift;

    my $base_dir    = $self->base_dir;
    my $config_mode = $self->get_config_mode;

    open(my $fh, '<', File::Spec->catfile($base_dir, 'config', "${config_mode}.json")) or die $!;
    my $lines = join('', <$fh>);
    close($fh) or die $!;

    JSON::decode_json($lines);
}

1;
