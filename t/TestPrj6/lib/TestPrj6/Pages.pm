package TestPrj6::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;

use Atelier::Plugin::Config::Perl;

use Plack::Request;
sub create_request { Plack::Request->new(shift->env) }

1;
