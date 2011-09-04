package TestPrj6::Pages::Root;
use parent qw/TestPrj6::Pages/;

use Atelier::Plugin::Exception;
use TestPrj6::Exception;

sub dispatch_index {
    my $self = shift;

    my $message = 'Hello,world.';

    my $content = $self->encoder->encode($message);
    response [
        200,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($content),
        ],
        [$content]
    ];

    $content = $self->encoder->encode('not ok');
    return [
        500,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($content),
        ],
        [$content]
    ];
}

sub dispatch_hoge {
    my $self = shift;

    throw 'TestPrj6::Exception::Hoge';

    my $content = $self->encoder->encode('not ok');
    return [
        500,
        [
         'Content-Type'   => 'text/plain; charset=utf8',
         'Content-Length' => length($content),
        ],
        [$content]
    ];
}

1;
