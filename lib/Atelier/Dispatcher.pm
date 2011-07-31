package Atelier::Dispatcher;
use strict;
use warnings;

use 5.10.0;
use Data::Validator;

use Atelier;
use Atelier::Util;

sub new {
    state $rule = Data::Validator->new(
        app_name => +{ isa => 'Str' },
        pages    => +{ isa => 'ArrayRef[Str]' },
        prefix   => +{ isa => 'Str', default => 'dispatch_' }
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    bless(+{ %$args } => $class);
}

sub app_pages {
    my $self = shift;

    $self->{app_pages} ||= "$self->{app_name}::Pages";
}

sub dispatches {
    my($self, $pages) = @_;

    $self->{dispatches}{$pages} ||= do {
        my $prefix = $self->{prefix};
        [ grep { m{^$prefix} } Atelier::Util::get_all_subs($pages) ];
    };
}

sub is_pages_enable {
    my($self, $pages) = @_;

    $self->{pages_enable}{$pages} ||= ($pages ~~ $self->{pages}); # smart matching
}

sub is_dispatch_enable {
    my($self, $pages, $dispatch) = @_;
    return unless $self->is_pages_enable($pages);

    $self->{dispatch_enable}{$pages}{$dispatch} ||= ($dispatch ~~ $self->dispatches($pages)); # smart matching
}

sub dispatch {
    state $rule = Data::Validator->new(
        env => +{ isa => 'HashRef' },
    )->with('Method');
    my($self, $args) = $rule->validate(@_);

    my $route = $self->router($args->{env});
    return $self->app_pages->status_404 unless($route && $route->{pages} && $route->{dispatch});

    my $pages    = $self->app_pages . '::' . delete($route->{pages});
    my $dispatch = $self->{prefix} .         delete($route->{dispatch});

    if ( $self->is_dispatch_enable($pages, $dispatch) ) {
        my $app_obj = $pages->new(
            env      => $args->{env},
            dispatch => $dispatch,
            args     => $route,
        );

        local $Atelier::CONTEXT;
        Atelier->set_context($app_obj);

        return $app_obj->exec;
    }
    else {
        return $self->app_pages->status_404;
    }
}

1;
