package Atelier::Dispatcher::RouterSimple;
use strict;
use warnings;

use 5.10.0;

use parent qw/Atelier::Dispatcher/;
use Atelier::Util;

use Router::Simple;
use Data::Validator;

sub import {
    my $class  = shift;
    my $caller = caller;

    my $router_simple = Router::Simple->new;
    Atelier::Util::add_method(
        add_to => $class,
        name   => 'router_simple',
        method => sub { $router_simple },
    );

    my %export_sugars = (
        connect => sub ($$) { ## no critic
            state $param_rule = Data::Validator->new(
                pages    => +{ isa => 'Str', },
                dispatch => +{ isa => 'Str', optional => 1 },
                method   => +{ isa => 'Str', default  => 'ANY' },
            );
            $_[1] = $param_rule->validate(%{ $_[1] });
            $router_simple->connect(@_);
        },
        submapper => sub ($$) { ## no critic
            state $param_rule = Data::Validator->new(
                pages    => +{ isa => 'Str', },
                dispatch => +{ isa => 'Str', optional => 1 },
                method   => +{ isa => 'Str', default  => 'ANY' },
            );
            $_[1] = $param_rule->validate(%{ $_[1] });
            $router_simple->submapper(@_);
        },
    );

    foreach my $name (keys %export_sugars) {
        Atelier::Util::add_method(
            add_to => $caller,
            name   => $name,
            method => $export_sugars{$name},
        );
    }

    no strict 'refs';
    unshift(@{"${caller}::ISA"}, $class);
}

sub router {
    my($self, $env) = @_;

    my $param  = $self->router_simple->match($env);
    return unless($param);

    my $method = uc( delete $param->{method} );

    return $param if (($method eq 'ANY') or ($method eq $env->{REQUEST_METHOD}));
}

1;