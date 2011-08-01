use strict;
use warnings;
use Test::More;

use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj4/lib';
use t::Util;

test_require('JSON');
plan tests => 2;

use JSON qw/decode_json/;

my $app = Atelier->create_app(app => 'TestPrj4');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/');
        my $res = $cb->($req);
        is $res->content, 'Hello,world';
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/json/');
        my $res = $cb->($req);
        is_deeply decode_json($res->content), +{
            hoge  => 'fuga',
            hello => 'world',
            japan => 'にほん',
            deep  => +{
                deep => +{
                    deep => 'deep'
                },
            },
        };
    };

