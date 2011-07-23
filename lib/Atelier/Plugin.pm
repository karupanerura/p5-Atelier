package Atelier::Plugin;
use strict;
use warnings;

use Carp;
use Atelier::Util;

sub import {
    my $class  = shift;
    my $caller = caller;

    Carp::croak(q{This module can't use. This is parent module.}) if ($class eq __PACKAGE__) ;

    {
        no strict 'refs'; ## no critic

        if ($class->can('__pre_export')) {
            local *{"${class}::pages"} = sub { $caller };
            $class->__pre_export(@_);
        }

        my @methods =
            grep { not m{^_} }
            grep { not m{^(import|AUTOLOAD|DESTROY)$} }
            Atelier::Util::get_all_subs($class);

        foreach my $method (@methods) {
            *{"${caller}::${method}"} = *{${"${class}::"}{$method}}{CODE};
        }

        if ($class->can('__post_export')) {
            local *{"${class}::pages"} = sub { $caller };
            $class->__post_export(@_);
        }
    }
}

1;
