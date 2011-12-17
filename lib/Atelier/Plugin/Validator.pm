package Atelier::Plugin::Validator;
use strict;
use warnings;

use Atelier::Plugin -base;
use Atelier::Plugin::Trigger '-depend-isa';
use Carp ();

our $PREFIX = 'valid_';

sub __pre_export {
    pages()->add_trigger(
        BEFORE_DISPATCH => sub {
            my $self = shift;

            $self->validate;
        }
    );
}

sub validator { Carp::croak('this is abstruct method.') }

sub valid_method {
    my $self = shift;

    return $PREFIX . $self->action;
}

sub validate {
    my $self = shift;

    my $valid_method = $self->valid_method;
    if ($self->can($valid_method)) {
        $self->$valid_method($self->validator);
    }
}

1;
