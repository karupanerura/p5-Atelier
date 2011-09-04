package Atelier::Plugin::Exception;
use strict;
use warnings;

use parent qw/Atelier::Plugin/;

use Atelier::Exception;
use Try::Tiny;
use Atelier::Util;

# sugers 
sub throw    ($;$) { (@_ == 1) ? $_[0]->throw : $_[1]->throw }                               ## no critic
sub response ($;$) { Atelier::Exception::PSGIResponse->response((@_ == 1) ? $_[0] : $_[1]) } ## no critic

# override
sub __pre_export {
    my $class = shift;

    if ( pages()->isa('Atelier::Pages') ) {
        my $super = pages()->can('exec');
        Atelier::Util::rewrite_method(
            rewrite_to => 'Atelier::Pages',
            name       => 'exec',
            method     => sub {
                my $self = shift;

                my $res;
                try {
                    $res = $self->$super();
                }
                catch {
                    my $e = $_;
                    if ( $e->isa('Atelier::Exception::PSGIResponse') ) {
                        $res = $e->to_response;
                    }
                    else {
                        die $e;
                    }
                };

                $res;
            }
        );
    }
}

1;
