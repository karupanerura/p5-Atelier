package Atelier::Pages;
use strict;
use warnings;

use 5.10.0;
use Carp;
use Encode;
use Data::Validator;
use Atelier::Util;

use Atelier::DataHolder (
    mk_translucents => [
        qw/charset mime_type stash renderer is_ascii/
    ],
    mk_classdatas => [
        qw/trigger_enable/
    ],
    mk_accessors => [
        qw/env dispatch template/
    ],
);

sub import {
    my $class = shift;

    Carp::croak(q{This module can't use. This is parent module.}) if ($class eq __PACKAGE__) ;

    $class->trigger_enable($class->can('trigger') ? 1 : 0);
    $class->stash(+{});
}

sub new {
    state $rule = Data::Validator->new(
        env => 'HashRef'
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    bless(+{ %$args } => $class);
}

sub create_request { die 'most override' }
sub req {
    my $self = shift;

    $self->{req} ||= $self->create_request;
}
*r = *req;

{
    my %encoder;
    sub encoder {
        my $self = shift;

        $encoder{$self->charset} ||= Encode::find_encoding($self->charset) or die qq{Can't found encoding "@{[$self->charset]}".};
    }
}

sub http_content_type {
    my $self = shift;

    $self->is_ascii ?
        $self->mime_type . '; ' . $self->charset:
        $self->mime_type;
}

sub exec {
    my $self = shift;

    $self->call_trigger(name => 'BEFORE_DISPATCH') if ($self->trigger_enable);
    my $response = $self->run_dispatch;
    $self->call_trigger(name => 'AFTER_DISPATCH')  if ($self->trigger_enable);

    Atelier::Util::is_psgi_response($response) ?
        $response:
        $self->finalize;
}

sub run_dispatch {
    my $self = shift;
    my $dispatch = $self->dispatch;

    $self->$dispatch;
}

sub render {
    my $self = shift;

    my $renderer = $self->renderer;
    $self->$renderer(@_);
}

sub finalize {
    my $self = shift;

    my $content = $self->render;
    $content    = $self->encoder->encode($content) if (Encode::is_utf8($content));

    [
        200,
        [
            'Content-Type'   => $self->http_content_type,
            'Content-Length' => length($content),
        ],
        [$content]
    ];
}

sub status_403 {
    my $message = '403 Forbidden';

    [
        403,
        [
            'Content-Type'   => 'text/plain',
            'Content-Length' => length($message),
        ],
        [$message]
    ];
}

sub status_404 {
    my $message = '404 Not Found';

    [
        404,
        [
            'Content-Type'   => 'text/plain',
            'Content-Length' => length($message),
        ],
        [$message]
    ];
}

sub redirect {
    my ($self, $uri, $scheme) = @_;

    [
       302,
       [
          'Location' => $self->make_absolute_uri($uri, $scheme),
       ],
       []
    ];
}

sub make_absolute_url {
    my($self, $uri, $scheme) = @_;

    return ($uri =~ m{^https?://}) ? $uri : $self->make_base_uri($scheme) . $uri;
}

sub make_base_url {
    my($self, $scheme) = @_;

    $scheme ||= $self->req->scheme;

    return "${scheme}://" . $self->env->{HTTP_HOST} . '/';
}

1;
