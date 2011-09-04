package Atelier::Util::TinyTemplate;
use strict;
use warnings;

use Carp ();

sub variable {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };
    my $name = $args->{name};

    return "__${name}__" if($name =~ m{^(?:PACKAGE|FILE|LINE|END|DATA)$});

    $args->{variables}{$name} or die(qq{Don't defined tempalte variable "$name".});
}

sub render_string {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

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
