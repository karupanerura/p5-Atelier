package Atelier::Plugin::Renderer::Tiffany;
use strict;
use warnings;

use parent qw/Atelier::Plugin/;
use Atelier::Util;

use 5.10.0;
use Tiffany;
use Data::Validator;

sub __pre_export {
    state $rule = Data::Validator->new(
        engine => +{ isa => 'Str'},
        option => +{ isa => 'HashRef' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);
    my $pages = pages();

    $pages->renderer('render_tiffany');

    my $tiffany = Tiffany->load($args->{engine}, $args->{option});

    Atelier::Util::add_method(
        add_to => $pages,
        name   => 'tiffany',
        method => sub { $tiffany },
    );
}

sub render_tiffany {
    my $self = shift;
    my $html = $self->tiffany->render($self->template, $self->stash);

    $self->call_trigger(
        name => 'HTML_FILTER',
        cb => sub {
            my $code = shift;
            $html = $code->($self, $html);
        }
    );

    return $html;
}

1;
