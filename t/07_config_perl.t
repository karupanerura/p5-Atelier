use strict;
use warnings;
use Test::More;

use Plack::Test;
use HTTP::Request;

use Atelier;
use lib 't/TestPrj5/lib';
use Encode;

plan tests => 2;

my $app = Atelier->create_app(app => 'TestPrj5');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/');
        my $res = $cb->($req);
        is $res->content, 'Hello,perl config world.';
    };

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new('GET' => 'http://localhost/japanese');
        my $res = $cb->($req);
        is Encode::decode('utf8', $res->content), 'ほげふが';
    };

