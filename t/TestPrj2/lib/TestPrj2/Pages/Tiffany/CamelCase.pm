package TestPrj2::Pages::Tiffany::CamelCase;
use parent qw/TestPrj2::Pages::Tiffany/;

sub dispatch_index {
    my $self = shift;

    $self->stash->{message} = 'CamelCase';
}

1;
