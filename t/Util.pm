package t::Util;
use strict;
use warnings;

use Atelier::Util;
use parent qw/Test::Builder::Module/;

our @EXPORT =
    grep { not m{^_} }
    grep { not m{^(import|AUTOLOAD|DESTROY)$} }
    Atelier::Util::get_all_subs(__PACKAGE__);

sub test_require {
    my @modules = @_;

    my $tb = __PACKAGE__->builder;

    foreach my $module (@modules) {
        my $version;

        if (ref($module) eq 'HASH') {
            while( ($module, $version) = each(%$module) ) {
                _test_require($tb, $module, $version);
            }
        }
        else {
            _test_require($tb, $module, $version);
        }
    }
}

sub _test_require {
    my($tb, $module, $version) = @_;

    my $require_mod  = "${module}";
       $require_mod .= " ${version}" if($version);

    eval("require ${require_mod};");
    $tb->plan(skip_all => qq{Test requires module "${require_mod}" but it's not found}) if($@);
}

1;
