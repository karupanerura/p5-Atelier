package Atelier::Pages;
use strict;
use warnings;

use 5.10.0;
use Carp ();
use Encode;
use Data::Validator;
use Atelier::Util;

use Atelier::Util::DataHolder (
    mk_translucents => [
        qw/charset mime_type stash renderer is_text/
    ],
    mk_accessors => [
        qw/env dispatch args template/
    ],
);

__PACKAGE__->mime_type('text/html');
__PACKAGE__->charset('UTF-8');
__PACKAGE__->is_text(1);
__PACKAGE__->stash(+{});

sub import {
    my $class = shift;

    Carp::croak(q{This module can't use. This is parent module.}) if ($class eq __PACKAGE__) ;

    $class->class_initalize(@_);
}

sub class_initalize {} # can override

sub new {
    state $rule = Data::Validator->new(
        env      => 'HashRef',
        dispatch => 'Str',
        args     => 'HashRef',
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

# dummy
sub call_trigger {}
sub add_trigger  { Carp::croak('You have to use Atelier::Plugin::Trigger if you want to use trigger.') }

{
    my %encoder;
    sub encoder {
        my $self = shift;

        $encoder{$self->charset} ||= Encode::find_encoding($self->charset) or die qq{Can't found encoding "@{[$self->charset]}".};
    }
}

{
    my %content_type;
    sub http_content_type {
        my $self = shift;

        $content_type{$self->charset}{$self->mime_type} ||= do {
            $self->is_text ?
                $self->mime_type . '; charset=' . $self->encoder->mime_name:
                $self->mime_type;
        };
    }
}

sub exec {
    my $self = shift;

    $self->call_trigger('BEFORE_DISPATCH');
    my $result = $self->run_dispatch;
    $self->call_trigger('AFTER_DISPATCH');

    my $res = $self->renderer ?
        $self->finalize:
        $result;

    $self->call_trigger('RESPONSE_FILTER' => sub { shift->($self, $res) });

    $res;
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
            'X-Content-Type-Options' => 'nosniff',
        ],
        [ $content ]
    ];
}

sub status_403 {
    my $self    = shift;
    my $message = '403 Forbidden';

    $self->renderer(undef) if ref($self);
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
    my $self    = shift;
    my $message = '404 Not Found';

    $self->renderer(undef) if ref($self);
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

    $self->renderer(undef);
    [
       302,
       [
          'Location' => $self->make_absolute_url($uri, $scheme),
       ],
       []
    ];
}

sub make_absolute_url {
    my($self, $uri, $scheme) = @_;

    return ($uri =~ m{^https?://}) ? $uri : $self->make_base_url($scheme) . $uri;
}

sub make_base_url {
    my($self, $scheme) = @_;

    $scheme ||= $self->req->scheme;

    return "${scheme}://" . $self->env->{HTTP_HOST} . '/';
}

sub base_dir {
    my $class = Atelier::Util::wantclass($_[0]);

    my $base_dir = Atelier::Util::base_dir($class);

    Atelier::Util::add_method(
        add_to => $class,
        name   => 'base_dir',
        method => sub { $base_dir }
    );

    $base_dir;
}

1;
