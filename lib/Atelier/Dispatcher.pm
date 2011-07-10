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

    $self->{dispatches}{$pages} ||= [
        grep { m{^dispatch_} } Atelier::Util::get_all_subs($pages)
    ];
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

    my $route = $self->rule($args->{env});
    return $self->app_pages->status_404 unless $route;

    my $pages    = $self->app_pages . "::$route->{pages}";
    my $dispatch = "dispatch_$route->{dispatch}";

    if ( $self->is_dispatch_enable($pages, $dispatch) ) {
        my $app_obj = $pages->new(
            env => $args->{env}
        );
        $app_obj->dispatch($dispatch);

        local $Atelier::CONTEXT;
        Atelier->set_context($app_obj);

        return $app_obj->exec;
    }
    else {
        return $self->app_pages->status_404;
    }
}

1;
