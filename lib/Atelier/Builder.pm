package Atelier::Builder;
use strict;
use warnings;

use 5.10.0;

use Dist::Maker;
use Data::Validator;

sub run {
    state $rule = Data::Validator->new(
        app_name => +{ isa => 'Str' },
        flavor   => +{ isa => 'Str', default => 'Default' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    Dist::Maker->run('init', $args->{app_name}, "Atelier::$args->{flavor}");
}

1;
