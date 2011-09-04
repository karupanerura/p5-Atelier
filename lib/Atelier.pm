package Atelier;
use strict;
use warnings;

use Module::Find;
use Module::Load;

our $VERSION = '0.03';

{
    our $CONTEXT; # You can localize this variable in your application.
    sub context     { $CONTEXT }
    sub set_context { $CONTEXT = $_[1] }
}

sub create_app {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    my $pages_class      = "$args->{app}::Pages";
    my $dispatcher_class = "$args->{app}::Dispatcher";

    load($pages_class);
    my @pages = useall($pages_class);

    load($dispatcher_class);
    my $dispatcher = $dispatcher_class->new(
        app_name => $args->{app},
        pages    => \@pages,
        exists($args->{prefix}) ? (prefix => $args->{prefix}) : (),
    );

    sub { $dispatcher->dispatch(env => shift) };
}

sub{'More fun and creative'}->('for your web development life.');
__END__

=head1 NAME

Atelier - Lightweight web application framework.

=head1 SYNOPSIS

  # app.psgi
  use Atelier;
  use Plack::Builder;

  builder {
      Atelier->create_app(
          app => 'YourApp', # pass your app namespace
      );
  };

  # YourApp::Dispatcher
  use parent qw/Atelier::Dispatcher::CamelCase/;

  1;

  # YourApp::Pages
  use parent qw/Atelier::Pages/;

  use Plack::Request;
  sub create_request{ Plack::Request->new(shift->env) };

  1;

  # YourApp::Pages::Root
  use parent qw/YourApp::Pages/;

  sub dispatch_index { # "/" or "/index" path route to this dispatch.
      my $self = shift;

      [
         200,
         [ 'Cotent-Type' => 'text/plain' ],
         [ 'Hello,world!' ],
      ];    
  }

=head1 DESCRIPTION

Atelier is lightweight web application framework.
This WAF is very pluggable and useful.

=head2 Sledge like interface.

Atelier is Sledge like interface.

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

L<Router::Simple> L<Tiffany>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
