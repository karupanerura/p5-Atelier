package __APP_NAME__::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;

sub create_request { Plack::Request->new(shift->env) }

1;
