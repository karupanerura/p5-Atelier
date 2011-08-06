package TestPrj4::Pages::Root;
use strict;
use warnings;

use parent qw/TestPrj4::Pages/;

sub dispatch_index {
    my $self = shift;

    my $message = $self->encoder->encode('Hello,world.');

    [
        200,
        [
            'Content-Type'   => 'text/plain' ,
             'Content-Length' => length($message),
        ],
        [ $message ]
    ];
}

1;
