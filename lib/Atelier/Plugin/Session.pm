package Atelier::Plugin::Session;
use strict;
use warnings;

use parent qw/Atelier::Plugin/;

sub session {
    my $self = shift;

    $self->{session} ||= $self->create_session();
}

1;
