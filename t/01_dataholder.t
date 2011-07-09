package Hoge;
use Atelier::DataHolder (
    mk_classdatas   => [qw/foo bar/],
    mk_translucents => [qw/hoge fuga/],
    mk_accessors    => [qw/test/],
);

package Fuga;
our @ISA = qw/Hoge/;

package main;
use Test::More tests => 39;

# classdata accessor like using
ok(Hoge->can('hoge'));
is(Hoge->hoge, undef);
is(Hoge->hoge('hoge'), 'hoge');
is(Hoge->hoge, 'hoge');

# no edit other translucent
ok(Hoge->can('fuga'));
is(Hoge->fuga, undef);
is(Hoge->fuga('fuga'), 'fuga');
is(Hoge->fuga, 'fuga');

# override test
ok(Fuga->can('fuga'));
is(Fuga->fuga, 'fuga');
is(Fuga->fuga('fuga2'), 'fuga2');
is(Hoge->fuga, 'fuga');
is(Fuga->fuga, 'fuga2');

# classdata accessor testing
ok(Hoge->can('foo'));
is(Hoge->foo, undef);
is(Hoge->foo('hoge'), 'hoge');
is(Hoge->foo, 'hoge');

# no edit other classdata
ok(Hoge->can('bar'));
is(Hoge->bar, undef);
is(Hoge->bar('fuga'), 'fuga');
is(Hoge->bar, 'fuga');

# override test
ok(Fuga->can('bar'));
is(Fuga->bar, 'fuga');
is(Fuga->bar('fuga2'), 'fuga2');
is(Hoge->bar, 'fuga');
is(Fuga->bar, 'fuga2');

my $obj = bless(+{} => Hoge);

# class accessor like using
is($obj->hoge, 'hoge');
is($obj->hoge('fuga'), 'fuga');

# override test
is($obj->hoge, 'fuga');
is(Hoge->hoge, 'hoge');

# no edit other translucent
is($obj->fuga, 'fuga');
is($obj->fuga('hoge'), 'hoge');

# override test
is($obj->fuga, 'hoge');
is(Hoge->fuga, 'fuga');

# accessor testing
ok($obj->can('test'));
is($obj->test, undef);
is($obj->test('hoge'), 'hoge');
is($obj->test, 'hoge');
is($obj->{test}, 'hoge');
