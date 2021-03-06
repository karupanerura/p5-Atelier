package Atelier::Util;
use strict;
use warnings;

use 5.10.0;
use Data::Validator;
use File::Spec;
use File::Basename ();
use Sub::Identify ();
use B::Hooks::EndOfScope;

use parent qw/Exporter/;

our(@EXPORT_OK, %EXPORT_TAGS);
on_scope_end {
    @EXPORT_OK =
        grep { not m{^_} }
        grep { not m{^(?:import|AUTOLOAD|DESTROY|BEGIN|CHECK|END)$} }
        __PACKAGE__->get_all_subs;
    $EXPORT_TAGS{all} = \@EXPORT_OK;
};

sub get_all_subs($) { ## no critic
    my $class = shift;

    {
        no strict 'refs'; ## no critic
        my $symbol_table = \%{"${class}::"};
        my @methods =
            grep { Sub::Identify::stash_name($class->can($_)) eq $class }
            grep { defined(*{$symbol_table->{$_}}{CODE}) }
            (keys %$symbol_table);

        wantarray ? @methods : \@methods;
    }
}

sub get_all_isa($) { ## no critic
    _get_all_isa(shift, +{});
}

sub _get_all_isa {
    my($class, $searched_hash) = @_;

    my @class_isa = do {
        no strict 'refs';
        grep { not exists $searched_hash->{$_} } @{"${class}::ISA"};
    };

    foreach my $isa (@class_isa) {
        next if(exists $searched_hash->{$isa});
        _get_all_isa($isa, $searched_hash);
        $searched_hash->{$isa} = 1;
    }

    keys %$searched_hash;
}

sub get_all_methods ($) { ## no critic
    my $class = shift;

    my @class_isa = (get_all_isa($class), $class);

    my @methods = ();
    foreach my $klass (@class_isa) {
        push(@methods, get_all_subs($klass));
    }

    wantarray ? @methods : \@methods;
}

sub add_method {
    state $rule = Data::Validator->new(
        add_to => +{ isa => 'Str' },
        name   => +{ isa => 'Str' },
        method => +{ isa => 'CodeRef' },
    );
    my $args = $rule->validate(@_);

    {
        no strict 'refs'; ## no critic
        *{"$args->{add_to}::$args->{name}"} = $args->{method};
    }
}

sub rewrite_method {
    state $rule = Data::Validator->new(
        rewrite_to => +{ isa => 'Str' },
        name       => +{ isa => 'Str' },
        method     => +{ isa => 'CodeRef' },
    );
    my $args = $rule->validate(@_);

    {
        no strict   'refs';     ## no critic
        no warnings 'redefine'; ## no critic
        *{"$args->{rewrite_to}::$args->{name}"} = $args->{method};
    }
}

sub uri_path_dir {
    my $path = shift;

    # 'd' is dummy string
    File::Basename::dirname($path . 'd') . '/';
}

sub clean_path {
    my $path = shift;

    1 while($path =~ s{(?:(?<=/)\.?/|^\./|[^/]+/\.{2}/)}{});

    $path;
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

sub wantclass($) { ## no critic
    ref($_[0]) || $_[0]
}

1;
