package Atelier::Plugin::Exception;
use strict;
use warnings;

use Atelier::Plugin -base;

use Atelier::Exception;
use Try::Tiny;
use Atelier::Util;
use Carp ();

# sugers
sub throw    ($;$) { (@_ == 1) ? $_[0]->throw : $_[1]->throw }                               ## no critic
sub response ($;$) { Atelier::Exception::PSGIResponse->response((@_ == 1) ? $_[0] : $_[1]) } ## no critic

# override
sub __pre_export {
    my $class = shift;

    if ( pages()->isa('Atelier::Pages') ) {
        my $super = pages()->can('exec');
        Atelier::Util::add_method(
            add_to     => pages(),
            name       => 'exec',
            method     => sub {
                my $self = shift;

                my $res;
                try {
                    local $SIG{__DIE__} = sub { Carp::confess(@_) };
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
