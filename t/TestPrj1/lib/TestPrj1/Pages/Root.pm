package TestPrj1::Pages::Root;
use strict;
use warnings;

use parent qw/TestPrj1::Pages/;

sub dispatch_index {
    my $self = shift;

    my $message = $self->encoder->encode('Hello,world');

    return [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($message),
        ],
        [ $message ]
    ];
}

sub dispatch_exists_page {
    my $self = shift;

    my $message = $self->encoder->encode('Exists');

    return [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($message),
        ],
        [ $message ]
    ];
}

1;
