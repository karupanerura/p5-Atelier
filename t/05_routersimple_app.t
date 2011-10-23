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

        $req = HTTP::Request->new('POST' => 'http://localhost/');
        $res = $cb->($req);
        is $res->content, 'Hello,world';

        $req = HTTP::Request->new('GET' => 'http://localhost/no_exists_page');
        $res = $cb->($req);
        like $res->content, qr/404 Not Found/;

        $req = HTTP::Request->new('GET' => 'http://localhost/test/');
        $res = $cb->($req);
        like $res->content, qr/404 Not Found/;

        $req = HTTP::Request->new('POST' => 'http://localhost/test/');
        $res = $cb->($req);
        is $res->content, 'Test,world';

        $req = HTTP::Request->new('GET' => 'http://localhost/echo/hoge');
        $res = $cb->($req);
        is $res->content, 'hoge';

        $req = HTTP::Request->new('GET' => 'http://localhost/echo/fuga');
        $res = $cb->($req);
        is $res->content, 'fuga';

        $req = HTTP::Request->new('POST' => 'http://localhost/echo/fuga');
        $res = $cb->($req);
        like $res->content, qr/404 Not Found/;
    };
