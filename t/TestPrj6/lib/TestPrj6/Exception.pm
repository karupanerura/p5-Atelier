package TestPrj6::Exception;
use parent qw/Atelier::Exception/;

package TestPrj6::Exception::Hoge;
use parent -norequire, qw/TestPrj6::Exception/;

sub description { 'Hoge exception' }

1;
