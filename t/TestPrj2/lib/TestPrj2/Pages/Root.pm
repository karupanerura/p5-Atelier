package TestPrj2::Pages::Root;
use parent qw/TestPrj2::Pages/;

__PACKAGE__->renderer(undef);
__PACKAGE__->charset('UTF-8');

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
