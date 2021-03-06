package Atelier::Pages;
use strict;
use warnings;

use 5.10.0;
use Carp ();
use Encode;
use Data::Validator;
use Atelier::Util;
use Plack::Request;

use Atelier::Util::DataHolder (
    mk_translucents => [
        qw/charset mime_type stash renderer is_text/
    ],
    mk_accessors => [
        qw/env dispatch args template render_result action prefix/
    ],
);

# set defaults
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
        prefix   => 'Str',
        action   => 'Str',
        args     => 'HashRef',
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    bless(+{ %$args, dispatch => $args->{prefix} . $args->{action} } => $class);
}

sub create_request { Plack::Request->new(shift->env) } # you should override
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
    state $rule = Data::Validator->new(
        template => +{ isa => 'Str',     optional => 1 },
        option   => +{ isa => 'HashRef', optional => 1 },
    )->with('Method', 'Sequenced');
    my($self, $args) = $rule->validate(@_);

    return $self->render_result || do {
        $self->template($args->{template}) if (exists $args->{template});
        $self->stash(+{
            %{ $self->stash },
            %{ $args->{option} }
        }) if (exists $args->{option});

        my $renderer = $self->renderer;
        my $result = $self->$renderer(@_);
        $self->render_result($result);

        $result;
    };
}

sub finalize {
    my $self = shift;

    my $content = $self->render;
    $content    = $self->encoder->encode($content) if($self->is_text);

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

sub status_403_content_type { 'text/plain'    } # can override
sub status_403_message      { '403 Forbidden' } # can override
sub status_403 {
    my $self    = shift;
    my $message = $self->status_403_message;

    $self->renderer(undef) if ref($self);
    [
        403,
        [
            'Content-Type'   => $self->status_403_content_type,
            'Content-Length' => length($message),
        ],
        [$message]
    ];
}

sub status_404_content_type { 'text/plain'    } # can override
sub status_404_message      { '404 Not Found' } # can override
sub status_404 {
    my $self    = shift;
    my $message = $self->status_404_message;

    $self->renderer(undef) if ref($self);
    [
        404,
        [
            'Content-Type'   => $self->status_404_content_type,
            'Content-Length' => length($message),
        ],
        [$message]
    ];
}

sub redirect_status { 302 }
sub redirect {
    my ($self, $uri, $scheme) = @_;

    $self->renderer(undef);
    [
       $self->redirect_status,
       [
          'Location' => $self->make_absolute_url($uri, $scheme),
       ],
       []
    ];
}

sub make_absolute_url {
    my($self, $uri, $scheme) = @_;

    return ($uri =~ m{^https?://}) ? $uri:
           ($uri =~ m{^/}) ? $self->make_base_url($scheme) . Atelier::Util::clean_path($uri):
           $self->make_base_url($scheme) . Atelier::Util::clean_path(Atelier::Util::uri_path_dir($self->env->{PATH_INFO}).$uri);
}

sub make_base_url {
    my($self, $scheme) = @_;

    $scheme ||= $self->env->{'psgi.url_scheme'};

    return "${scheme}://" . $self->env->{HTTP_HOST};
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
