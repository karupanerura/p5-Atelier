package TestPrj2::Pages::Tiffany;
use parent qw/TestPrj2::Pages/;

sub dispatch_index {
    my $self = shift;

    $self->stash->{message} = 'Hello,world';
}

1;
