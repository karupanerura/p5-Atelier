package Atelier::Util::TinyTemplate;
use strict;
use warnings;

use 5.10.0;
use Data::Validator;
use Carp ();

sub variable {
    state $rule = Data::Validator->new(
        name      => +{ isa => 'Str' },
        variables => +{ isa => 'HashRef' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);
    my $name = $args->{name};

    return "__${name}__" if($name =~ m{^(?:PACKAGE|FILE|LINE|END|DATA)$});

    $args->{variables}{$name} or die(qq{Don't defined tempalte variable "$name".});
}

sub render_string {
    state $rule = Data::Validator->new(
        template  => +{ isa => 'Str' },
        variables => +{ isa => 'HashRef' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    my %variables;
    foreach my $key (keys %{$args->{variables}}) {
        $variables{uc($key)} = $args->{variables}{$key};
    }

    my $template = $args->{template};
    $template =~ s{
        __([A-Z_]+?)__
    }{
        $class->variable(
            name      => $1,
            variables => \%variables
        );
    }msxige;

    $template;
}

1;
