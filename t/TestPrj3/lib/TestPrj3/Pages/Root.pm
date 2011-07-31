package TestPrj3::Pages::Root;
use parent qw/TestPrj3::Pages/;

__PACKAGE__->charset('utf8');

sub dispatch_index {
    my $self = shift;

    my $hello_world = $self->encoder->encode('Hello,world');

    return [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($hello_world),
        ],
        [$hello_world]
    ];
}

sub dispatch_test {
    my $self = shift;

    my $test_world = $self->encoder->encode('Test,world');

    return [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($test_world),
        ],
        [$test_world]
    ];
}

sub dispatch_echo {
    my $self = shift;

    my $text = $self->encoder->encode($self->args->{text});

    return [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($text),
        ],
        [$text]
    ];
}

1;
