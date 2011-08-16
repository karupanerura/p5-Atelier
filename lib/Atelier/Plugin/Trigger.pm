package Atelier::Plugin::Trigger;
use strict;
use warnings;

use 5.10.0;
use parent qw/Atelier::Plugin/;
use Atelier::DataHolder;
use Data::Validator;

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
    state $rule = Data::Validator->new(
        name => +{ isa => 'Str' },
        cb   => +{ isa => 'CodeRef', optional => 1 },
    )->with('Method', 'Sequenced');
    my($self, $args) = $rule->validate(@_);

    foreach my $trigger (@{$self->trigger->{$args->{name}}}) {
        exists($args->{cb}) ?
            $args->{cb}->($trigger):
            $trigger->($self);
    }
}

sub add_trigger {
    state $rule = Data::Validator->new(
        name => +{ isa => 'Str' },
        cb   => +{ isa => 'CodeRef' },
    )->with('Method', 'Sequenced');
    my($self, $args) = $rule->validate(@_);

    push(@{ $self->trigger->{$args->{name}} }, $args->{cb});
}

1;
