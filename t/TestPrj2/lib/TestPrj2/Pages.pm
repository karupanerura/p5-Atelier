package TestPrj2::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;
use File::Spec;

use Atelier::Plugin::Renderer::Tiffany (
    engine => 'Text::Xslate',
    option => +{
        path   => [ File::Spec->catfile(__PACKAGE__->base_dir, 'tmpl') ],
        syntax => 'TTerse',
        suffix => '.html',
    },
);

use Atelier::Plugin::Trigger;
use Atelier::Plugin::TmplDispatcher::PathInfo;

sub create_request { Plack::Request->new(shift->env) }

1;
