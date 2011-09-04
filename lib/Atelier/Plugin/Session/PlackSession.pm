package Atelier::Plugin::Session::PlackSession;
use strict;
use warnings;

use parent qw/Atelier::Plugin::Session/;

use Plack::Session;
sub create_session { Plack::Session->new(shift->env) }

1;
