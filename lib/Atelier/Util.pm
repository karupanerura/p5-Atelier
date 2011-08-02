package Atelier::Util;
use strict;
use warnings;


use File::Spec;

use parent qw/Exporter/;

our(@EXPORT_OK, %EXPORT_TAGS);
@EXPORT_OK =
    grep { not m{^_} }
    grep { not m{^(import|AUTOLOAD|DESTROY)$} }
    __PACKAGE__->get_all_subs;
$EXPORT_TAGS{all} = \@EXPORT_OK;

BEGIN {
    require Clone; # require only(don't import)
}

sub get_all_subs($) { ## no critic
    my $class = shift;

    {
        no strict 'refs'; ## no critic
        my $symbol_table = \%{"${class}::"};
        my @methods =
            grep { defined(*{$symbol_table->{$_}}{CODE}) }
           (keys %$symbol_table);

        wantarray ? @methods : \@methods;
    }
}

sub add_method {
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    {
        no strict 'refs'; ## no critic
        *{"$args->{add_to}::$args->{name}"} = $args->{method};
    }
}

sub base_dir($) { ## no critic
    my $path = shift;

    $path =~ s{::}{/}g;

    if (my $libpath = $INC{"${path}.pm"}) {
        $libpath =~ s{(?:blib/)?lib/(?:[\d\w]+/)*${path}\.pm$}{};
        File::Spec->rel2abs($libpath or './');
    }
    else {
        File::Spec->rel2abs('./');
    }
}

sub datacopy($) { ## no critic
    ref($_[0]) ? Clone::clone($_[0]) : $_[0]
}

sub wantclass($) { ## no critic
    ref($_[0]) || $_[0]
}

1;
