package Atelier::Dispatcher::CamelCase;
use strict;
use warnings;

use parent qw/Atelier::Dispatcher/;

sub rule {
    my($self, $env) = @_;

    if ($env->{PATH_INFO} =~ m{^/?(?:(.*)/(.*?))$}) {
        return +{
            pages    => $1 ? path2pages($1) : 'Root',
            dispatch => $2 ? lc($2)         : 'index',
        };
    }
}

sub path2pages ($) { join('::', map { camelize($_) } split('/', shift)) } ## no critic
sub camelize   ($) { join('',   map { ucfirst($_)  } split('_', shift)) } ## no critic

1;
