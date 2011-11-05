use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Atelier;

Atelier->create_app(
    app => 'TestPrj5'
);
