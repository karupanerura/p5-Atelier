package TestPrj3::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;

sub create_request { Plack::Request->new(shift->env) }

1;
