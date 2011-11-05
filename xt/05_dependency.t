#!/usr/bin/perl -w
use strict;
use warnings;
use Test::Module::Used;
my $used = Test::Module::Used->new(
    meta_file    => 'META.yml',    # META file (YAML or JSON which contains module requirement information)
    perl_version => '5.010',       # expected perl version which is used for ignore core-modules in testing
);
my @features = qw/JSON YAML::Syck Tiffany Plack::Session Router::Simple/;
$used->push_exclude_in_libdir(@features);
$used->push_exclude_in_testdir(@features);
$used->push_exclude_in_testdir(qw/Test::Perl::Critic/);
$used->ok;

