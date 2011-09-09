package Atelier::Plugin::TmplDispatcher::PathInfo;
use strict;
use warnings;

use Atelier::Plugin -base;

sub __pre_export {
    my $class  = shift;
    my $args   = (@_ == 1) ? $_[0] : +{ @_ };
    my $suffix = $args->{suffix} || '.html';

    pages()->add_trigger('BEFORE_DISPATCH' => sub {
        my $self = shift;

        my $template = $self->env->{PATH_INFO};
        $template =~ s{/$}{/index};
        $template =~ s{^/}{};
        $self->template($template . $suffix);
    });
}

1;
