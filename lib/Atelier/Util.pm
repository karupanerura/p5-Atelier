package Atelier::Util;
use strict;
use warnings;

use parent qw/Exporter/;
our @EXPORT_OK =
    grep { not m{^_} }
    grep { not m{^(import|AUTOLOAD|DESTROY)$} }
    __PACKAGE__->get_all_subs;

sub get_all_subs {
    my $class = shift;

    {
        no strict 'refs';
        my $symbol_table = \%{"${class}::"};
        my @methods =
            grep { defined(*{$symbol_table->{$_}}{CODE}) }
           (keys %$symbol_table);

        wantarray ? @methods : \@methods;
    }
}

sub is_psgi_response {
    (ref($_[0]) eq 'ARRAY') and
        (int($_[0]->[0]) == $_[0]->[0]) and
        (ref($_[0]->[1]) eq 'ARRAY') and
        (ref($_[0]->[2]) eq 'ARRAY');
}

1;
