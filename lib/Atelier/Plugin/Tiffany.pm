package Atelier::Plugin::Tiffany;
use strict;
use warnings;

use parent qw/Atelier::Plugin/;
use Atelier::DataHolder;

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

    $pages->charset('UTF-8');
    $pages->mime_type('text/html');
    $pages->is_ascii(1);
    $pages->renderer('render_tiffany');

    Atelier::DataHolder->mk_dataholder(
        create_to    => $pages,
        mk_classdata => 'tiffany',
        mk_accessor  => 'template',
    );
    $pages->tiffany( Tiffany->load($args->{engine}, $args->{option}) );
}

sub render_tiffany {
    my $self = shift;
    my $html = $self->tiffany->render($self->template, $self->stash);

    if ( $self->trigger_enable ) {
        $self->call_trigger(
            name => 'HTML_FILTER',
            cb => sub {
                my $code = shift;
                $html = $code->($self, $html);
            }
        );
    }

    return $html;
}

1;
