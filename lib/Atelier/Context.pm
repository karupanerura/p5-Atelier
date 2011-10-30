package Atelier::Context;
use strict;
use warnings;

use Atelier;

sub import {
    my $caller = caller;

    {
        no strict 'refs';
        *{"${caller}::c"} = sub () { ## no critic
            Atelier->context
        };
    }
}

1;
