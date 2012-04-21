use strict;
use warnings;
use Test::More;

use t::Util;
use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj7/lib';

test_require('FormValidator::Lite');
plan tests => 3;

my $app = Atelier->create_app(app => 'TestPrj7');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/');
        my $res = $cb->($req);
        like $res->content, qr/Error/;

        $req = HTTP::Request->new('GET' => 'http://localhost/?text=');
        $res = $cb->($req);
        like $res->content, qr/Error/;

        $req = HTTP::Request->new('GET' => 'http://localhost/?text=a');
        $res = $cb->($req);
        like $res->content, qr/Hello,world/;
    };
