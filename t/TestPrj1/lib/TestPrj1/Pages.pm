package TestPrj1::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;

__PACKAGE__->charset('UTF-8');

sub create_request { Plack::Request->new(shift->env) }

1;
