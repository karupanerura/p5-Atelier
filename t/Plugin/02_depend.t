package Fuga;
use t::Plugin::Foo;

1;

package main;
use Module::Load;
load('t::Plugin::Hoge');
load('t::Plugin::Foo');
use Test::More tests => 10;

ok(t::Plugin::Hoge->can('pre_export_ok'));
ok(Fuga->pre_export_ok);
ok(t::Plugin::Hoge->can('post_export_ok'));
ok(Fuga->post_export_ok);

ok(t::Plugin::Hoge->can('export_method'));
ok(Fuga->export_method);
ok(t::Plugin::Foo->can('export_method2'));
ok(Fuga->export_method2);
ok(t::Plugin::Hoge->_no_export_method);
ok(!Fuga->can('_no_export_method'));
