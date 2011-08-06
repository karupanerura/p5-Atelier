package Atelier::Flavor::Simple;
use strict;
use warnings;

use parent 'Atelier::Flavor';

sub flavor_name { 'Simple' }

sub dir_list {
    return [
          'htdocs',
          'lib',
          'lib/__APP_NAME__',
          'lib/__APP_NAME__/Pages',
          't',
          'tmpl',
          'xt'
        ];

}

sub file_list { 
    return [
          {
            'app.psgi' => 'use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), \'extlib\', \'lib\', \'perl5\');
use lib File::Spec->catdir(dirname(__FILE__), \'lib\');
use Atelier;
use Plack::Builder;

builder {
    enable \'Plack::Middleware::Static\',
        path => qr{^(?:/static/|/robot\\.txt$|/favicon.ico$)},
        root => File::Spec->catdir(dirname(__FILE__), \'htdocs\');

    Atelier->create_app(
        app => \'__APP_NAME__\'
    );
};
'
          },
          {
            'Makefile.PL' => 'use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => \'__APP_NAME__\',
    AUTHOR        => \'Some Person <person@example.com>\',
    VERSION_FROM  => \'lib/__APP_NAME__.pm\',
    PREREQ_PM     => {
        \'Atelier\' => \'0.02\',
    },
    MIN_PERL_VERSION => \'5.010000\',
    (-d \'xt\' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => \'t/*.t xt/*.t\',
        },
    ) : (),
);
'
          },
          {
            'lib/__APP_NAME__.pm' => 'package __APP_NAME__;
use strict;
use warnings;

require 5.010000;

our $VERSION = \'0.01\';

1;
__END__
'
          },
          {
            'lib/__APP_NAME__/Dispatcher.pm' => 'package __APP_NAME__::Dispatcher;
use parent qw/Atelier::Dispatcher::CamelCase/;

1;
'
          },
          {
            'lib/__APP_NAME__/Pages.pm' => 'package __APP_NAME__::Pages;
use strict;
use warnings;

use parent qw/Atelier::Pages/;
use File::Spec;

my $suffix = \'.html\';
use Atelier::Plugin::Renderer::Tiffany (
    engine => \'Text::Xslate\',
    option => +{
        path   => [ File::Spec->catfile(__PACKAGE__->base_dir, \'tmpl\') ],
        syntax => \'TTerse\',
        suffix => $suffix,
    },
);

use Atelier::Plugin::Trigger;
__PACKAGE__->add_trigger(
    name => \'BEFORE_DISPATCH\',
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
'
          },
          {
            'lib/__APP_NAME__/Pages/Root.pm' => 'package __APP_NAME__::Pages::Root;
use parent qw/__APP_NAME__::Pages/;

sub dispatch_index {
    my $self = shift;

    $self->stash->{message} = \'Hello,world\';
}

1;
'
          },
          {
            't/00_compile.t' => 'use strict;
use Test::More tests => 1;

BEGIN { use_ok \'__APP_NAME__\' }
'
          },
          {
            'tmpl/index.html' => '<!DOCTYPE html>
<html lang="en">
  <head>
    <title>[% message %]</title>
  </head>
  <body>
    <p>[% message %]</p>
  </body>
</html>
'
          },
          {
            'xt/01_podspell.t' => 'use Test::More;
eval q{ use Test::Spelling };
plan skip_all => "Test::Spelling is not installed." if $@;
add_stopwords(map { split /[\\s\\:\\-]/ } <DATA>);
$ENV{LANG} = \'C\';
all_pod_files_spelling_ok(\'lib\');
__DATA__
__APP_NAME__
'
          },
          {
            'xt/02_perlcritic.t' => 'use strict;
use Test::More;
eval {
    require Test::Perl::Critic;
    Test::Perl::Critic->import( -profile => \'xt/perlcriticrc\');
};
plan skip_all => "Test::Perl::Critic is not installed." if $@;
all_critic_ok(\'lib\');
'
          },
          {
            'xt/03_pod.t' => 'use Test::More;
eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();
'
          },
          {
            'xt/perlcriticrc' => '[TestingAndDebugging::ProhibitNoStrict]
allow=refs
'
          }
        ];

}

1;
