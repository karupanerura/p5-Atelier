package Atelier::Util::DataHolder;
use strict;
use warnings;

use 5.10.0;
use Data::Validator;
use Atelier::Util qw/wantclass/;

use Carp ();
use Data::Clone qw/clone/;

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
    state $rule = Data::Validator->new(
        create_to       => { isa => 'Str' },
        mk_classdatas   => { isa => 'ArrayRef[Str]', optional => 1, },
        mk_translucents => { isa => 'ArrayRef[Str]', optional => 1, },
        mk_accessors    => { isa => 'ArrayRef[Str]', optional => 1, },
        mk_classdata    => { isa => 'Str', optional => 1, },
        mk_translucent  => { isa => 'Str', optional => 1, },
        mk_accessor     => { isa => 'Str', optional => 1, },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

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
    state $rule = Data::Validator->new(
        create_to => { isa => 'Str' },
        name      => { isa => 'ArrayRef[Str]' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    foreach my $name ( @{$args->{name}} ){
        $class->_mk_classdata(
            create_to => $args->{create_to},
            name      => $name,
        );
    }
}

sub _mk_classdata {
    state $rule = Data::Validator->new(
        create_to => { isa => 'Str' },
        name      => { isa => 'Str' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);
    
    my $create_to = $args->{create_to};
    my $name      = $args->{name};

    my $holder;

    Atelier::Util::add_method(
        add_to => $create_to,
        name   => $name,
        method => sub {
            (wantclass($_[0]) ne $create_to) ?
                ( $class->_mk_classdata(create_to => wantclass($_[0]), name => $name)->(wantclass($_[0]), (@_ == 2) ? $_[1] : clone($holder)) ):
                ( (@_ == 2) ? $holder = $_[1] : $holder );
        },
    );
}

sub mk_translucents { shift->_mk_translucents(create_to => scalar(caller), name => \@_) }
sub _mk_translucents {
    state $rule = Data::Validator->new(
        create_to => { isa => 'Str' },
        name      => { isa => 'ArrayRef[Str]' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    foreach my $name ( @{$args->{name}} ){
        $class->_mk_translucent(
            create_to => $args->{create_to},
            name      => $name,
        );
    }
}

sub _mk_translucent {
    state $rule = Data::Validator->new(
        create_to => { isa => 'Str' },
        name      => { isa => 'Str' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);
    
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
                    ( exists($_[0]->{$name}) ? $_[0]->{$name} : ($_[0]->{$name} = clone($holder)) ):
                ($_[0] ne $create_to) ?
                    ( $class->_mk_translucent(create_to => $_[0], name => $name)->($_[0], (@_ == 2) ? $_[1] : clone($holder)) ):
                    ( (@_ == 2) ? ( $holder = $_[1] ) : ( $holder ) );
        },
    );
}


sub mk_accessors { shift->_mk_accessors(create_to => scalar(caller), name => \@_) }
sub _mk_accessors {
    state $rule = Data::Validator->new(
        create_to => { isa => 'Str' },
        name      => { isa => 'ArrayRef[Str]' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    foreach my $name ( @{$args->{name}} ){
        $class->_mk_accessor(
            create_to => $args->{create_to},
            name      => $name,
        );
    }
}

sub _mk_accessor {
    state $rule = Data::Validator->new(
        create_to  => { isa => 'Str' },
        name       => { isa => 'Str' },
        permission => { isa => 'Str', default => 'rw' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    my $permission = $args->{permission};
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
