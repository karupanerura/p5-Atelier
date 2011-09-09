package t::Plugin::Hoge;
use Atelier::Plugin -base;

my $PRE_EXPORT_OK;
my $POST_EXPORT_OK;
sub __pre_export  { $PRE_EXPORT_OK  = (pages() eq 'Fuga') }
sub __post_export { $POST_EXPORT_OK = (pages() eq 'Fuga') }

sub pre_export_ok     { $PRE_EXPORT_OK }
sub post_export_ok    { $POST_EXPORT_OK }
sub _no_export_method { shift eq __PACKAGE__ }
sub export_method     { shift eq 'Fuga' }

1;
