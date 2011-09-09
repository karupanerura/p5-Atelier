package Atelier::Plugin::Session;
use strict;
use warnings;

use Atelier::Plugin -base;

sub session {
    my $self = shift;

    $self->{session} ||= $self->create_session();
}

1;
