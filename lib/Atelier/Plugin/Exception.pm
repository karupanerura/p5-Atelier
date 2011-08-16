package Atelier::Plugin::Exception;
use strict;
use warnings;

use parent qw/Atelier::Plugin/;

use Atelier::Exception;
use Try::Tiny;

sub throw    { $_[0]->throw }
sub response { Atelier::Exception::PSGIResponse->response($_[0]) }

# override
sub exec {
    my $self = shift;

    my $res = try {
        $self->SUPER::exec;
    }
    catch {
        my $e = $_;
        if ($e->isa('Atelier::Exception::PSGIResponse')) {
            $res = $e->to_response;
        }
        else {
            die $e;
        }
    };

    $res;
}

1;
