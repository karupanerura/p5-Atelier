package Hoge;
use parent qw/Atelier::Plugin/;

my $PRE_EXPORT_OK;
my $POST_EXPORT_OK;
sub __pre_export  { $PRE_EXPORT_OK  = (pages() eq 'Fuga') }
sub __post_export { $POST_EXPORT_OK = (pages() eq 'Fuga') }

sub pre_export_ok     { $PRE_EXPORT_OK }
sub post_export_ok    { $POST_EXPORT_OK }
sub _no_export_method { shift eq 'Hoge' }
sub export_method     { shift eq 'Fuga' }

package Fuga;
Hoge->import;

package main;
use Test::More tests => 8;

ok(Hoge->can('pre_export_ok'));
ok(Fuga->pre_export_ok);
ok(Hoge->can('post_export_ok'));
ok(Fuga->post_export_ok);

ok(Hoge->can('export_method'));
ok(Fuga->export_method);
ok(!Fuga->can('_no_export_method'));
ok(Hoge->_no_export_method);
