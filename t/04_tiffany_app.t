use strict;
use warnings;
use Test::More;

use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj2/lib';
use t::Util;

test_require('Tiffany');
plan tests => 5;

my $app = Atelier->create_app(app => 'TestPrj2');

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
        my $req = HTTP::Request->new('GET' => 'http://localhost/no_exists_page');
        my $res = $cb->($req);
        like $res->content, qr/404 Not Found/;
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/exists_page');
        my $res = $cb->($req);
        is $res->content, 'Exists';
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/tiffany/');
        my $res = $cb->($req);
        like $res->content, qr/Hello,world/;
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/tiffany/camel_case/');
        my $res = $cb->($req);
        like $res->content, qr/CamelCase/;
    };

