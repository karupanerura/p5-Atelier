package TestPrj5::Pages::Root;
use parent qw/TestPrj5::Pages/;

sub dispatch_index {
    my $self = shift;

    my $message = $self->encoder->encode($self->config->{message});

    return [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($message),
        ],
        [$message]
    ];
}


sub dispatch_japanese {
    my $self = shift;

    my $message = $self->encoder->encode($self->config->{japanese_message});

    return [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($message),
        ],
        [$message]
    ];
}

1;
