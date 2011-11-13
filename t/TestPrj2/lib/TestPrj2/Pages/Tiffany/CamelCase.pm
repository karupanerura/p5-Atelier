package TestPrj2::Pages::Tiffany::CamelCase;
use parent qw/TestPrj2::Pages::Tiffany/;

sub dispatch_index {
    my $self = shift;

    $self->stash->{message} = 'CamelCase';
}

sub dispatch_index_clone {
    my $self = shift;

    return $self->render(
        'tiffany/camel_case/index.html' => +{
            message => 'CamelCase'
        },
    );
}

1;
