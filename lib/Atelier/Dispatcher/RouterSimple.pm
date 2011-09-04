package Atelier::Dispatcher::RouterSimple;
use strict;
use warnings;

use parent qw/Atelier::Dispatcher/;
use Atelier::Util;

use Router::Simple;

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
        any => sub ($$) { ## no critic
            $router_simple->connect(@_);
        },
        get => sub ($$) { ## no critic
            $router_simple->connect(@_, +{ method => [qw/HEAD GET/] });
        },
        post => sub ($$) { ## no critic
            state $param_rule = Data::Validator->new(
                $router_simple->connect(@_, +{ method => 'POST' });
        },
        connect => sub ($$) { ## no critic
            # XXX: This is DEPRECATED. You should use any, get, post.
            $_[1]->{method} = uc($_[1]->{method});
            my $option = (!$_[1]->{method} or $_[1]->{method} eq 'ANY') ? +{} : +{ method => $_[1]->{method} };
            $router_simple->connect(@_, $option);
        },
        submapper => sub ($$) { ## no critic
            # XXX: This is DEPRECATED. You should use any, get, post.
            $_[1]->{method} = uc($_[1]->{method});
            my $option = (!$_[1]->{method} or $_[1]->{method} eq 'ANY') ? +{} : +{ method => $_[1]->{method} };
            $router_simple->submapper(@_, $option);
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

    return $self->router_simple->match($env);
}

1;
