package Dist::Maker::Template::Atelier::Minimum;
use utf8;
use Mouse;
use MouseX::StrictConstructor;

extends 'Dist::Maker::Template::Default';
with 'Dist::Maker::Template';

sub distribution {
    return <<'DIST';
: cascade Default;

:# @@ Makefile.PL

: after mpl_requires {
requires 'Atelier' => '0.10';
: }
: after mpl_test_requires {
test_requires 'Plack::Test';
test_requires 'HTTP::Request';
: }

:# @@ lib/$dist.module_path
: after module_code -> {
use Atelier;

sub to_app {
    my $class = shift;
    Atelier->create_app(app => $class);
}
: } # module_code

: override synopsis {
  # app.psgi
  <: $dist.module :>->to_app;
: }

: override basic_t_tests -> {
use warnings;
use utf8;

use Test::More;
use Plack::Test;
use HTTP::Request;

test_psgi
    app => <: $dist.module :>->to_app,
    client => sub {
        my $cb  = shift;

        subtest '/' => sub {
            my $req = HTTP::Request->new(GET => 'http://localhost/');
            my $res = $cb->($req);
            like $res->content, qr/Hello,world!/;
        };
    };
: }

: after extra_files -> {
@@ lib/<: $dist.path :>/Pages.pm
package <: $dist.module :>::Pages;
use strict;
use warnings;
use utf8;

use parent qw/Atelier::Pages/;
use Atelier::Plugin::Config::Perl;

1;

@@ lib/<: $dist.path :>/Dispatcher.pm
package <: $dist.module :>::Dispatcher;
use strict;
use warnings;
use utf8;

use parent qw/Atelier::Dispatcher::CamelCase/;

1;

@@ lib/<: $dist.path :>/Pages/Root.pm
package <: $dist.module :>::Pages::Root;
use strict;
use warnings;
use utf8;

use parent qw/<: $dist.module :>::Pages/;

sub dispatch_index {
    my $self = shift;

    return [
        200,
        [
         'Content-Type' => 'text/plain'
        ],
        [ 'Hello,world!' ]
    ];
}

1;

@@ config/development.pl
+{}

@@ app.psgi
use strict;
use warnings;
use utf8;

use Plack::Builder;
use <: $dist.module :>;

builder {
    enable 'XFramework', framework => 'Atelier';
    <: $dist.module :>->to_app
};
: } # extra_files
DIST
}

no Mouse;
__PACKAGE__->meta->make_immutable();
__END__

=head1 NAME

    Dist::Maker::Template::Atelier::Minimum - The minimum Atelier application template

=cut

