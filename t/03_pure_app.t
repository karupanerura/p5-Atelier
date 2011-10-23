use strict;
use warnings;
use Test::More tests => 4;

use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj1/lib';

my $app = Atelier->create_app(app => 'TestPrj1');

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

        $req = HTTP::Request->new('GET' => 'http://localhost/camel_case/');
        $res = $cb->($req);
        like $res->content, qr/CamelCase/;
    };
