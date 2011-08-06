package TestPrj5::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;

use Plack::Request;
use Atelier::Plugin::Config::Perl;

sub create_request { Plack::Request->new(shift->env) }

1;
