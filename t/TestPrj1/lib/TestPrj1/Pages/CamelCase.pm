package TestPrj1::Pages::CamelCase;
use strict;
use warnings;

use parent 'TestPrj1::Pages';

sub dispatch_index {
    my $self = shift;

    my $message = $self->encoder->encode('CamelCase');

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
