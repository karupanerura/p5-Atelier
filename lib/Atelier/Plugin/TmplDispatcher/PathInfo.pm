package Atelier::Plugin::TmplDispatcher::PathInfo;
use strict;
use warnings;

sub __pre_export {
    my $class  = shift;
    my $args   = (@_ == 1) ? $_[0] : +{ @_ };
    my $suffix = $args->{suffix} || '.html';

    pages()->add_trigger(
        name => 'BEFORE_DISPATCH',
        cb   => sub {
            my $self = shift;

            my $template = $self->env->{PATH_INFO};
            $template =~ s{/$}{/index};
            $template =~ s{^/}{};
            $self->template($template . $suffix);
        },
    );
}

1;
