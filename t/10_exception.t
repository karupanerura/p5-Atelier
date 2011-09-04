use strict;
use warnings;
use Test::More tests => 6;

use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj6/lib';

my $app = Atelier->create_app(app => 'TestPrj6');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/');
        my $res = $cb->($req);
        ok $res->is_success;
        is $res->content, 'Hello,world.';
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/no_exists_page');
        my $res = $cb->($req);
        ok !$res->is_success;
        like $res->content, qr/404 Not Found/;
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/hoge');
        my $res = $cb->($req);
        ok !$res->is_success;
        like $res->content, qr/Hoge exception/;
    };
