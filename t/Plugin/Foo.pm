package t::Plugin::Foo;
use Atelier::Plugin -base;
use t::Plugin::Hoge -depend;

sub export_method2 { shift eq 'Fuga' }

1;
