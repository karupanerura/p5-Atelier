use inc::Module::Install;
name 'Atelier';
all_from 'lib/Atelier.pm';
readme_from 'lib/Atelier.pm';
readme_pod_from 'lib/Atelier.pm';
githubmeta;

# requires '';

requires 'parent';
requires 'Plack';
requires 'Exporter';
requires 'Module::Find';
requires 'Module::Load';
requires 'Clone';
requires 'Encode';
requires 'Data::Validator';
requires 'Tiffany';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
