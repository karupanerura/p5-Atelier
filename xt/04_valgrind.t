use strict;
use warnings;
use Test::More;
use t::Util;
test_use('Test::Valgrind');
leaky();
