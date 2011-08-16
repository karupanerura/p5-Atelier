package Atelier::Exception;
use strict;
use warnings;

use Carp;
use Atelier::DataHolder (
    mk_classdatas => [qw/do_trace/],
);

use overload '""' => \&stringify;

__PACKAGE__->do_trace(0);

# borrowed from Sledge::Exception
sub new {
    my $class = shift;

    # XXX: エラーの分類別にサブクラスを作るべきなの
    # 直接このクラス使ったらダメよ
    if ( $class eq __PACKAGE__ ) {
        Carp::croak("Don't use $class directly. please make subclass");
    }

    my $args  = @_ ?
        (@_ == 1 ? $_[0] : +{ @_ }) :
        +{ msg => $class->description };
    my $self = bless(+{ %$args } => $class);

    if ($class->do_trace) {
        my $i = 1;
        my($pkg, $file, $line) = caller($i++);
        my @stacktrace;
        while ($pkg) {
            push @stacktrace, Atelier::Exception::StackTrace->new(
                pkg  => $pkg,
                file => $file,
                line => $line,
            );
            ($pkg, $file, $line) = caller($i++);
        }
        pop @stacktrace;
        $self->{'-stacktrace'} = \@stacktrace;
    }

    return $self;
}

sub stacktrace {
    my $self = shift;
    return $self->{'-stacktrace'} || [];
}

sub description { 'Atelier core exception (Abstract)' }

sub throw { Carp::croak(shift->new(@_)) }

sub stringify {
    my $self = shift;

    my $text = exists $self->{msg} ? $self->{msg} : 'Died';
    foreach my $trace ( @{$self->stacktrace} ) {
        $text .= sprintf(" at %s(%s) line %d.\n", $trace->pkg, $trace->file, $trace->line);
    }

    return $text;
}

package Atelier::Exception::StackTrace;
use strict;
use warnings;

sub new {
    my($class, %p) = @_;
    bless \%p, $class;
}

sub pkg  { shift->{pkg} }
sub file { shift->{file} }
sub line { shift->{line} }

package Atelier::Exception::PSGIResponse;
use strict;
use warnings;

use Carp;
use parent -norequire, 'Atelier::Exception';

sub response {
    my $class = shift;
    my $response = shift;

    Carp::croak($class->new(response => $response));
}

sub to_response { $_[0]->{response} }

package Atelier::Exception::Sample;
use strict;
use warnings;

use Carp;
use parent -norequire, 'Atelier::Exception';

sub description { 'Message' }

1;
