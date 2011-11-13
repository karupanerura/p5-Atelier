use strict;
use warnings;
use Test::More;

use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj2/lib';
use t::Util;

test_require('Tiffany', 'Text::Xslate');
plan tests => 5;

my $app = Atelier->create_app(app => 'TestPrj2');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/');
        my $res = $cb->($req);
        is $res->content, 'Hello,world';

        $req = HTTP::Request->new('GET' => 'http://localhost/no_exists_page');
        $res = $cb->($req);
        like $res->content, qr/404 Not Found/;

        $req = HTTP::Request->new('GET' => 'http://localhost/exists_page');
        $res = $cb->($req);
        is $res->content, 'Exists';

        $req = HTTP::Request->new('GET' => 'http://localhost/tiffany/');
        $res = $cb->($req);
        like $res->content, qr/Hello,world/;

        $req = HTTP::Request->new('GET' => 'http://localhost/tiffany/camel_case/');
        $res = $cb->($req);
        like $res->content, qr/CamelCase/;

        $req = HTTP::Request->new('GET' => 'http://localhost/tiffany/camel_case/index_clone');
        $res = $cb->($req);
        like $res->content, qr/CamelCase/;
    };

