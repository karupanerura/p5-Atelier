use strict;
use warnings;
use Test::More;

use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj3/lib';
use t::Util;

test_require('Router::Simple');
plan tests => 8;

my $app = Atelier->create_app(app => 'TestPrj3');

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
        my $req = HTTP::Request->new('POST' => 'http://localhost/');
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
        my $req = HTTP::Request->new('GET' => 'http://localhost/test/');
        my $res = $cb->($req);
        like $res->content, qr/404 Not Found/;
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('POST' => 'http://localhost/test/');
        my $res = $cb->($req);
        is $res->content, 'Test,world';
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/echo/hoge');
        my $res = $cb->($req);
        is $res->content, 'hoge';
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/echo/fuga');
        my $res = $cb->($req);
        is $res->content, 'fuga';
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('POST' => 'http://localhost/echo/fuga');
        my $res = $cb->($req);
        like $res->content, qr/404 Not Found/;
    };
