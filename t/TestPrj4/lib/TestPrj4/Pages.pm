package TestPrj4::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;

use Plack::Request;
sub create_request { Plack::Request->new(shift->env) }

1;
