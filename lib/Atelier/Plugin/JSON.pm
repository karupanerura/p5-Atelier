package Atelier::Plugin::JSON;
use strict;
use warnings;

use parent qw/Atelier::Plugin/;
use Atelier::Util;

use JSON;

my %_ESCAPE = (
    '+' => '\\u002b', # do not eval as UTF-7
    '<' => '\\u003c', # do not eval as HTML
    '>' => '\\u003e', # ditto.
);

sub __pre_export {
    my $pages = pages();

    $pages->mime_type('application/json');
    $pages->renderer('render_json');

    my $json = JSON->new->ascii(1);

    Atelier::Util::add_method(
        add_to => $pages,
        name   => 'json',
        method => sub { $json },
    );
}

sub render_json {
    my $self = shift;
    my $json = $self->json->encode($self->stash);

    # for IE7 JSON venularity.
    # see http://www.atmarkit.co.jp/fcoding/articles/webapp/05/webapp05a.html
    $json =~ s!([+<>])!$_ESCAPE{$1}!g;

    if ( ( $self->req->user_agent || '' ) =~ /Chrome/ and
         ( $self->req->env->{'HTTP_X_REQUESTED_WITH'} || '' ) ne 'XMLHttpRequest' ) {
        $self->mime_type('text/html');
    }

    # add UTF-8 BOM if the client is Safari
    if ( ( $self->req->user_agent || '' ) =~ m/Safari/ and $self->encoder->mime_name eq 'UTF-8' ) {
        $json = "\xEF\xBB\xBF" . $json;
    }

    return $json;
}

1;
