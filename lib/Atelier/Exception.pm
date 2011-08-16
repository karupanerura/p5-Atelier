package Atelier::Exception;
use strict;
use warnings;

use Carp;
use overload '""' => \&inspect;

sub throw {
    my ($class, %args) = @_;

    # XXX: エラーの分類別にサブクラスを作るべきなの
    # 直接このクラス使ったらダメよ
    if ( $class eq __PACKAGE__ ) {
        Carp::croak("Don't use $class directly. please make subclass");
    }

    my ($caller, $call_path, $line_number) = caller(1);
    $args{caller} = $call_path;
    $args{line_number} = $line_number;

    Carp::croak($class->new(%args));
}

sub new {
    my ($class, %args) = @_;

    my $self = \%args;
    bless $self, $class;
    return $self;
}

sub msg {
    $_[0]->{msg};
}

sub inspect {
    my $self = shift;
    sprintf("<#%s: msg: %s> at %s line %s\n", ref $self, $self->msg, $self->{caller}, $self->{line_number});
}

package Atelier::Exception::PSGIResponse;
use strict;
use warnings;

use parent -norequire, 'Atelier::Exception';

sub response    { shift->throw(@_) }
sub to_response { $_[0]->msg       }

1;
