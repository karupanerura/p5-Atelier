package TestPrj2::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;
use File::Spec;

my $suffix = '.html';
use Atelier::Plugin::Renderer::Tiffany (
    engine => 'Text::Xslate',
    option => +{
        path   => [ File::Spec->catfile(__PACKAGE__->base_dir, 'tmpl') ],
        syntax => 'TTerse',
        suffix => $suffix,
    },
);

use Atelier::Plugin::Trigger;
__PACKAGE__->add_trigger(
    name => 'BEFORE_DISPATCH',
    cb   => sub {
        my $self = shift;

        my $template = $self->env->{PATH_INFO};
        $template =~ s{/$}{/index};
        $template =~ s{^/}{};
        $self->template($template . $suffix);
    },
);

sub create_request { Plack::Request->new(shift->env) }

1;
