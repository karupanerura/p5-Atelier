package Atelier::Util;
use strict;
use warnings;

use 5.10.0;
use Data::Validator;

use parent qw/Exporter/;

our(@EXPORT_OK, %EXPORT_TAGS);
@EXPORT_OK =
    grep { not m{^_} }
    grep { not m{^(import|AUTOLOAD|DESTROY)$} }
    __PACKAGE__->get_all_subs;
$EXPORT_TAGS{all} = \@EXPORT_OK;

BEGIN {
    require Clone;# require only(don't import)
}

sub get_all_subs($) { ## no critic
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

my $http_status_code = qr{^(?:4(?:1[0-7]|0\d)|20[0-6]|30[0-57]|50[0-5]|10[01])$};
sub is_psgi_response($) { ## no critic
    (ref($_[0]) eq 'ARRAY') and
        ($_[0]->[0] =~ $http_status_code) and
        (ref($_[0]->[1]) eq 'ARRAY' and ((scalar(@{$_[0]->[1]}) % 2) == 0) ) and
        (ref($_[0]->[2]) eq 'ARRAY');
}

sub add_method {
    state $rule = Data::Validator->new(
        add_to => +{ isa => 'Str' },
        name   => +{ isa => 'Str' },
        method => +{ isa => 'CodeRef' },
    );
    my $args = $rule->validate(@_);

    {
        no strict 'refs';
        *{"$args->{add_to}::$args->{name}"} = $args->{method};
    }
}

sub datacopy($) { ## no critic
    ref($_[0]) ? Clone::clone($_[0]) : $_[0]
}

sub wantclass($) { ## no critic
    ref($_[0]) || $_[0]
}

1;
