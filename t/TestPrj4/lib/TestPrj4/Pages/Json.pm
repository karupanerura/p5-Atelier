package TestPrj4::Pages::Json;
use strict;
use warnings;

use parent qw/TestPrj4::Pages/;

use Atelier::Plugin::JSON;

__PACKAGE__->stash(+{
    hello => 'world'
});

sub dispatch_index {
    my $self = shift;

    $self->stash->{hoge}  = 'fuga';
    $self->stash->{japan} = 'にほん';
    $self->stash->{deep}  = +{ deep => +{deep => 'deep'} };
}

1;
