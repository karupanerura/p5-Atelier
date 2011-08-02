package Atelier::DataHolder;
use strict;
use warnings;

use Atelier::Util qw/datacopy wantclass/;

BEGIN {
    require Carp; # require only(don't import)
}

sub import {
    return if(@_ == 1);
    my $class = shift;
    my %args  = (@_ % 2) ? %{ $_[0] } : @_;

    $class->mk_dataholder(
        create_to => scalar(caller),
        %args,
    );
}

sub mk_dataholder {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    my @dataholders = grep { m{^mk_} } keys(%$args);
    foreach my $dataholder (@dataholders) {
        my $method = "_${dataholder}";
        $class->$method(
            create_to => $args->{create_to},
            name      => $args->{$dataholder},
        );
    }
}

sub mk_classdatas { shift->_mk_classdatas(create_to => scalar(caller), name => \@_) }
sub _mk_classdatas {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    foreach my $name ( @{$args->{name}} ){
        $class->_mk_classdata(
            create_to => $args->{create_to},
            name      => $name,
        );
    }
}

sub _mk_classdata {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };
    
    my $create_to = $args->{create_to};
    my $name      = $args->{name};

    my $holder;

    Atelier::Util::add_method(
        add_to => $create_to,
        name   => $name,
        method => sub {
            (wantclass($_[0]) ne $create_to) ?
                ( $class->_mk_classdata(create_to => wantclass($_[0]), name => $name)->(wantclass($_[0]), (@_ == 2) ? $_[1] : datacopy($holder)) ):
                ( (@_ == 2) ? $holder = $_[1] : $holder );
        },
    );
}

sub mk_translucents { shift->_mk_translucents(create_to => scalar(caller), name => \@_) }
sub _mk_translucents {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    foreach my $name ( @{$args->{name}} ){
        $class->_mk_translucent(
            create_to => $args->{create_to},
            name      => $name,
        );
    }
}

sub _mk_translucent {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };
    
    my $create_to = $args->{create_to};
    my $name      = $args->{name};

    my $holder;
    
    Atelier::Util::add_method(
        add_to => $create_to,
        name   => $name,
        method => sub {
            ref($_[0]) ?
                (@_ == 2) ?
                    ( $_[0]->{$name} = $_[1] ):
                    ( exists($_[0]->{$name}) ? $_[0]->{$name} : ($_[0]->{$name} = datacopy($holder)) ):
                ($_[0] ne $create_to) ?
                    ( $class->_mk_translucent(create_to => $_[0], name => $name)->($_[0], (@_ == 2) ? $_[1] : datacopy($holder)) ):
                    ( (@_ == 2) ? ( $holder = $_[1] ) : ( $holder ) );
        },
    );
}


sub mk_accessors { shift->_mk_accessors(create_to => scalar(caller), name => \@_) }
sub _mk_accessors {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    foreach my $name ( @{$args->{name}} ){
        $class->_mk_accessor(
            create_to => $args->{create_to},
            name      => $name,
        );
    }
}

sub _mk_accessor {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    my $permission = $args->{permission} || 'rw';
    my $name       = $args->{name};

    Atelier::Util::add_method(
        add_to => $args->{create_to},
        name   => $name,
        method => (
            ($permission eq 'rw') ? sub { (@_ == 2) ? $_[0]->{$name} = $_[1] : $_[0]->{$name} }:
            ($permission eq 'ro') ? sub { (@_ == 1) ? $_[0]->{$name} : Carp::croak('This accessor is read only.') }:
            ($permission eq 'wo') ? sub { (@_ == 2) ? $_[0]->{$name} = $_[1] : Carp::croak('This accessor is write only.') }:
            Carp::croak('permission not found.')
        ),
    );
}

1;

__END__

=pod

=head1
  Aterier::DataHolder - オブジェクトに引き継ぎ可能なClass::Data::Inheritable

=cut
