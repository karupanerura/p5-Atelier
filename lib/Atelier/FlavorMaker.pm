package Atelier::FlavorMaker;
use strict;
use warnings;

use File::Find;
use Fcntl ':flock';
use Encode;
use Cwd;
use Data::Dumper;
use Atelier::Util::TinyTemplate;

sub new {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };
    $args->{charset} ||= 'utf8';

    bless(+{ %$args } => $class);
}

sub encoder {
    my $self = shift;

    $self->{encoder} ||= Encode::find_encoding($self->{charset});
}

sub create {
    my $self = shift;

    $self->initalize;

    $self->{cwd} = Cwd::cwd();
    Cwd::chdir($self->{dir});
    find(+{
        wanted => sub {
            my $path = $File::Find::name;
            $path =~ s{^\./}{};
            return if($path eq '.');
 
            if (-f $path) {
                $self->add_file(path => $path);
            }
            elsif (-d $path) {
                $self->add_dir(path => $path);
            }
        },
        no_chdir => 1,
    }, '.');
    Cwd::chdir($self->{cwd});
    
    $self->finalize;
}

sub initalize {
    my $self = shift;

    $self->{dir_list}  = [];
    $self->{file_list} = [];
}

sub add_file {
    my $self  = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    open(my $fh, '<', $args->{path}) or die "Can't open file: $!";
    flock($fh, LOCK_SH);
    my $file = join('', map { $self->encoder->encode($_) }  <$fh>);
    flock($fh, LOCK_UN);
    close($fh);

    my $path     = $args->{path};
    my $app_name = quotemeta($self->{app_name});
    $file =~ s{$app_name}{__APP_NAME__}mg;
    $path =~ s{$app_name}{__APP_NAME__}mg;

    push(@{ $self->{file_list} }, +{ $path => $file } );
}

sub add_dir {
    my $self  = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    my $path     = $args->{path};
    my $app_name = quotemeta($self->{app_name});
    $path =~ s{$app_name}{__APP_NAME__}mg;

    push(@{ $self->{dir_list} }, $path);
}

sub finalize {
    my $self = shift;

    my $dir_list = Dumper($self->{dir_list});
    $dir_list  =~ s/^\$VAR1 =/return/;
    $self->{dir_list} = $dir_list;

    my $file_list = Dumper($self->{file_list});
    $file_list  =~ s/^\$VAR1 =/return/;
    $self->{file_list} = $file_list;

    $self->create_flavor;
}

sub create_flavor {
    my $self = shift;

    Atelier::Util::TinyTemplate->render_string(
        template  => join('', <DATA>),
        variables => +{
            flavor_version => $self->{version},
            flavor_name    => $self->{name},
            dir_list       => $self->{dir_list},
            file_list      => $self->{file_list},
        },
    );
}

sub DESTOROY {
    my $self = shift;

    Cwd::chdir($self->{cwd}) if($self->{cwd});
}

1;

__DATA__
package Atelier::Flavor::__FLAVOR_NAME__;
use strict;
use warnings;

use parent 'Atelier::Flavor';

our $VERSION = '__FLAVOR_VERSION__';

sub flavor_name { '__FLAVOR_NAME__' }

sub dir_list {
    __DIR_LIST__
}

sub file_list { 
    __FILE_LIST__
}

1;
