package Atelier::Plugin::Trigger;
use strict;
use warnings;

use parent qw/Atelier::Plugin/;
use Atelier::DataHolder;

sub __pre_export {
    my $class = shift;
    my $pages = pages();
    Atelier::DataHolder->_mk_translucent(
        create_to => $pages,
        name      => 'trigger',
    );

    $pages->trigger(+{});
}

sub call_trigger {
    my $self  = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    foreach my $trigger (@{$self->trigger->{$args->{name}}}) {
        exists($args->{cb}) ?
            $args->{cb}->($trigger):
            $trigger->($self);
    }
}

sub add_trigger {
    my $self  = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    push(@{ $self->trigger->{$args->{name}} }, $args->{cb});
}

1;
