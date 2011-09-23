package Atelier::Plugin;
use strict;
use warnings;

use Carp ();
use Atelier::Util;
use Module::Load;

use Atelier::Util::DataHolder (
    mk_classdatas => [qw/_depend/],
);

use List::MoreUtils ();

__PACKAGE__->_depend([]);

sub import {
    my $class  = shift;

    my($option, $import_to);
    if (@_ and $_[0] =~ m{^-(?:base|parent|depend|import)$}) {
        $option = shift;
        $import_to = ($option eq '-import') ? shift : caller;
    }
    else {
        $import_to = caller;
        $option = '-import';
    }

    Carp::croak(q{This module can't use. This is parent module.}) if ($class eq __PACKAGE__ and $option eq '-import') ;

    if ($option eq '-import') {
        no strict 'refs'; ## no critic

        unless ( $import_to->can('__atelier_plugin_loaded__') ) {
            Atelier::Util::DataHolder->_mk_classdata(
                create_to => $import_to,
                name      => '__atelier_plugin_loaded__',
            );
            $import_to->__atelier_plugin_loaded__([]);
        }
        my @plugins = @{ $import_to->__atelier_plugin_loaded__ };
        unless (List::MoreUtils::any { $class eq $_ } @plugins) {
            foreach my $depend ( @{ $class->_depend } ) {
                next if List::MoreUtils::any { $depend->{pkg} eq $_ } @plugins;
                load($depend->{pkg});
                $depend->{pkg}->import(
                    -import => $import_to,
                    $depend->{args} ?
                    @{$depend->{args}} :
                    ()
                );
                push( @{ $import_to->__atelier_plugin_loaded__ }, $depend->{pkg});
            }

            push( @{ $import_to->__atelier_plugin_loaded__ }, $class);
        }

        if ($class->can('__pre_export')) {
            local *{"${class}::pages"} = sub { $import_to };
            $class->__pre_export(@_);
        }

        my @methods =
            grep { not m{^_} }
            grep { not m{^(import|AUTOLOAD|DESTROY)$} }
            Atelier::Util::get_all_methods($class);

        foreach my $method (@methods) {
            *{"${import_to}::${method}"} = $class->can($method) or die 'Method not found.';
        }

        if ($class->can('__post_export')) {
            local *{"${class}::pages"} = sub { $import_to };
            $class->__post_export(@_);
        }
    }
    elsif ($option =~ m{^-(?:base|parent)$}) {
        no strict 'refs';
        unshift( @{"${import_to}::ISA"}, $class );
    }
    elsif ($option eq '-depend') {
        push( @{$import_to->_depend}, +{
            pkg  => $class,
            args => [ @_ ],
        });
    }
}

1;
