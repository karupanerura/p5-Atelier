package Atelier::Plugin::Validator::Lite;
use strict;
use warnings;

use Atelier::Plugin::Validator -base;
use FormValidator::Lite;

sub __pre_export {
    my $class = shift;
    FormValidator::Lite->load_constraints(@_);

    $class->SUPER::__pre_export;
}

sub validator {
    my $self = shift;
    $self->{_validator_lite} ||= FormValidator::Lite->new($self->req);
}

1;
