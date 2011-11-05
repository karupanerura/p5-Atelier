use inc::Module::Install;
name 'Atelier';
all_from 'lib/Atelier.pm';

sub my_author_recommend {
    my $module = shift;
    warn "You should exec 'cpanm ${module}' if you are this module author.";
}
eval "readme_from 'lib/Atelier.pm'; 1;"     or my_author_recommend 'Module::Install::ReadmeFromPod';
eval "readme_pod_from 'lib/Atelier.pm'; 1;" or my_author_recommend 'Module::Install::ReadmePodFromPod';
eval "githubmeta; 1;"                       or my_author_recommend 'Module::Install::GithubMeta';

# requires '';

requires 'Plack::Request';
requires 'Try::Tiny'; # this is Plack's require module
requires 'Module::Find';
requires 'Data::Validator';
requires 'Data::Clone';
requires 'List::MoreUtils';
requires 'Sub::Identify';
requires 'B::Hooks::EndOfScope';

# core module after perl 5.10.0
requires 'Exporter';
requires 'parent';
requires 'Module::Load';
requires 'Encode';
requires 'Fcntl';
requires 'Cwd';
requires 'Carp';
requires 'File::Find';
requires 'File::Path';
requires 'File::Spec';

features(
    'if use Atelier::Plugin::Renderer::Tiffany' => [
        -default => 0,
        recommends('Tiffany'),
    ],
    'if use Atelier::Plugin::Renderer::JSON' => [
        -default => 0,
        recommends('JSON'),
    ],
    'if use Atelier::Plugin::Config::JSON' => [
        -default => 0,
        recommends('JSON'),
    ],
    'if use Atelier::Plugin::Config::YAML' => [
        -default => 0,
        recommends('YAML::Syck'),
    ],
    'if use Atelier::Dispather::RouterSimple' => [
        -default => 0,
        recommends('Router::Simple'),
    ],
);

install_script('script/atelier-builder.pl');
install_script('script/atelier-flavormaker.pl');

tests 't/*.t t/*/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Builder::Module';
test_requires 'Plack::Test';
test_requires 'HTTP::Request';
test_requires 'Module::Find';
test_requires 'parent';
test_requires 'Sub::Identify';
test_requires 'B::Hooks::EndOfScope';

eval "auto_set_repository; 1;" or my_author_recommend 'Module::Install::Repository';
WriteAll;
