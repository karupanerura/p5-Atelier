package Test::Pages::Root;
use parent qw/Test::Pages/;

sub dispatch_index {
    my $self = shift;

    my $hello_world = Encode::encode('utf8', 'Hello,world.');

    return [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($hello_world),
        ],
        [$hello_world]
    ];
}

1;
