package TestPrj7::Pages::Root;
use strict;
use warnings;

use parent qw/TestPrj7::Pages/;
use Atelier::Plugin::Validator::Lite;

sub valid_index {
    my $self = shift;

    $self->validator->check(
        text => [qw/NOT_NULL/],
    );
}

sub dispatch_index {
    my $self = shift;

    $self->stash->{message} = $self->validator->has_error ? 'Error' : 'Hello,world';
}

1;
