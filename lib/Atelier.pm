package Atelier;
use strict;
use warnings;

use 5.10.0;
use Data::Validator;
use Module::Find;
use Module::Load;

our $VERSION = '0.01';

{
    our $CONTEXT; # You can localize this variable in your application.
    sub context     { $CONTEXT }
    sub set_context { $CONTEXT = $_[1] }
}

sub create_app {
    state $rule = Data::Validator->new(
        app => +{ isa => 'Str' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);
    
    my $pages_class      = "$args->{app}::Pages";
    my $dispatcher_class = "$args->{app}::Dispatcher";

    my @pages      = useall($pages_class);

    load($dispatcher_class);
    my $dispatcher = $dispatcher_class->new(
        pages => \@pages,
    );

    sub {
        my $app_obj = $dispatcher->dispatch(env => shift);

        local $Atelier::CONTEXT;
        Atelier->set_context($app_obj);

        $app_obj->exec;
    };
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

  # YourApp::Pages
  use parent qw/Atelier::Pages/;
  use Atelier::Plugin::Trigger;
  use Atelier::Plugin::Tiffany (
      engine => 'Text::Xslate',
      option => +{
          syntax => 'TTerse',
      },
  );

  use Plack::Request;
  __PACKAGE__->add_trigger(
      name => 'BEFORE_DISPATCH',
      cb   => sub {
          my $self = shift;
          $self->req( Plack::Request->new($self->env) );
      },
  );

  # YourApp::Pages::Hoge
  use parent qw/YourApp::Pages/;

  sub dispatch_hoge {
      my $self = shift;

      $self->stash->{hoge} = 'hoge';
  }

  # YourApp::Dispatcher
  use parent qw/Atelier::Dispatcher/; # comming soon

  # comming soon

=head1 DESCRIPTION

Atelier is lightweight web application framework.
This WAF is very pluggable and useful.

=head2 Sledge like interface.

Atelier is Sledge like interface.

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
