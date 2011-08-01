use inc::Module::Install;
name 'Atelier';
all_from 'lib/Atelier.pm';
readme_from 'lib/Atelier.pm';
readme_pod_from 'lib/Atelier.pm';
githubmeta;

# requires '';

requires 'parent';
requires 'Plack';
requires 'Module::Find';
requires 'Data::Validator';

requires 'Exporter';
requires 'Module::Load';
requires 'Clone';
requires 'Encode';
requires 'Fcntl';
requires 'Cwd';
requires 'Carp';
requires 'File::Find';
requires 'File::Path';
requires 'File::Spec';

features(
    'if use Atelier::Plugin::Tiffany' => [
        -default => 0,
        recommends('Tiffany'),
    ],
    'if use Atelier::Plugin::JSON' => [
        -default => 0,
        recommends('JSON'),
    ],
    'if use Atelier::Dispather::RouterSimple' => [
        -default => 0,
        recommends('Router::Simple'),
    ],
);

install_script('script/atelier-builder.pl');
install_script('script/atelier-flavormaker.pl');

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
