use inc::Module::Install;
name 'Atelier';
all_from 'lib/Atelier.pm';
readme_from 'lib/Atelier.pm';
readme_pod_from 'lib/Atelier.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
