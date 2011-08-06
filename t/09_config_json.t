use strict;
use warnings;
use Test::More;

use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj5/lib';
use Encode;
use t::Util;

test_require('JSON');
plan tests => 2;

my $app = Atelier->create_app(app => 'TestPrj5');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/json/');
        my $res = $cb->($req);
        is $res->content, 'Hello,json config world.';
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/json/japanese');
        my $res = $cb->($req);
        is Encode::decode('utf8', $res->content), 'ほげふが';
    };

