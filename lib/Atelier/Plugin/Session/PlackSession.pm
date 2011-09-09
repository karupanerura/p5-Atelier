package Atelier::Plugin::Session::PlackSession;
use strict;
use warnings;

use Atelier::Plugin::Session -base;

use Plack::Session;
sub create_session { Plack::Session->new(shift->env) }

1;
