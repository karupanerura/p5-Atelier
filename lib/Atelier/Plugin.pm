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
        $option = '-import';
        $import_to = caller;
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
                next if List::MoreUtils::any {
                    warn "isa: '$depend->{type}', pkg: '$depend->{pkg}'";
                    $depend->{type} eq 'isa'    ? $_->isa($depend->{pkg}):
                    $depend->{type} eq 'strict' ? ($_ eq $depend->{pkg}):
                    Carp::croak("Unknown depend type: '$depend->{type}'");
                } @plugins;
                Carp::croak("Yet load plugin '$depend->{pkg}'");
            }
            push( @{ $import_to->__atelier_plugin_loaded__ }, $class);
        }

        if ($class->can('__pre_export')) {
            $class->___pre_export($import_to, @_);
        }

        my @methods =
            grep { not m{^_} }
            grep { not m{^(?:import|pages|AUTOLOAD|DESTROY|BEGIN|CHECK|END)$} }
            Atelier::Util::get_all_methods($class);

        foreach my $method (@methods) {
            *{"${import_to}::${method}"} = $class->can($method) or die 'Method not found.';
        }

        if ($class->can('__post_export')) {
            $class->___post_export($import_to, @_);
        }
    }
    elsif ($option =~ m{^-(?:base|parent)$}) {
        no strict 'refs';
        unshift( @{"${import_to}::ISA"}, $class );
        *{"${import_to}::pages"} = sub { $import_to->_pages };
    }
    elsif ($option eq '-depend') {
        push( @{$import_to->_depend}, +{
            pkg  => $class,
            type => 'strict',
            args => [ @_ ],
        });
    }
    elsif ($option eq '-depend-isa') {
        push( @{$import_to->_depend}, +{
            pkg  => $class,
            type => 'isa',
            args => [ @_ ],
        });
    }
    else {
        Carp::croak("Unknown option: '${option}'");
    }
}

sub ___pre_export {
    my($class, $import_to, @args) = @_;

    no strict 'refs';
    local *{__PACKAGE__ . '::_pages'} = sub { $import_to };
    $class->__pre_export(@args);
}

sub ___post_export {
    my($class, $import_to, @args) = @_;

    no strict 'refs';
    local *{__PACKAGE__ . '::_pages'} = sub { $import_to };
    $class->__post_export(@args);
}

1;
