package t::Util;
use strict;
use warnings;

use parent qw/Test::Builder::Module/;
use Sub::Identify ();
use B::Hooks::EndOfScope;

our @EXPORT;
on_scope_end {
    @EXPORT =
        grep { not m{^_} }
        grep { not m{^(import|AUTOLOAD|DESTROY|BEGIN|CHECK|END)$} }
        __PACKAGE__->get_all_subs;
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

sub test_require {
    my @modules = @_;
    my $caller  = caller;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $tb = __PACKAGE__->builder;

    foreach my $module (@modules) {
        my $version;

        if (ref($module) eq 'HASH') {
            while( ($module, $version) = each(%$module) ) {
                _test_require($tb, $module, $version, $caller);
            }
        }
        else {
            _test_require($tb, $module, $version, $caller);
        }
    }
}

sub _test_require {
    my($tb, $module, $version, $caller) = @_;

    my $require_mod  = "${module}";
       $require_mod .= " ${version}" if($version);

    eval("{package ${caller}; require ${require_mod};}");
    $tb->plan(skip_all => qq{Test requires module "${require_mod}" but it's not found}) if($@);
}

sub test_use {
    my @modules = @_;
    my $caller  = caller;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $tb = __PACKAGE__->builder;

    foreach my $module (@modules) {
        my $version;

        if (ref($module) eq 'HASH') {
            while( ($module, $version) = each(%$module) ) {
                _test_use($tb, $module, $version, $caller);
            }
        }
        else {
            _test_use($tb, $module, $version, $caller);
        }
    }
}

sub _test_use {
    my($tb, $module, $version, $caller) = @_;

    my $require_mod  = "${module}";
       $require_mod .= " ${version}" if($version);

    eval("{package ${caller}; use ${require_mod};}");
    $tb->plan(skip_all => qq{Test requires module "${require_mod}" but it's not found}) if($@);
}

1;
