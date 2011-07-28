package Atelier::Flavor;
use strict;
use warnings;

use 5.10.0;
use Cwd;
use File::Path;
use Data::Validator;

sub flavor_name { die 'This is abstract method' }
sub file_list   { die 'This is abstract method' }
sub dir_list    { die 'This is abstract method' }

sub new {
    state $rule = Data::Validator->new(
        charset => +{ isa => 'Str' }
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    bless(+{ %$args } => $class);
}

sub create {
    my $self = shift;

    my $flavor_name = $self->flavor_name;
    my $base_dir = "$ENV{HOME}/.atelier/flavor/${flavor_name}";
    File::Path::mkpath($base_dir);

    $self->{cwd} = Cwd::cwd();
    Cwd::chdir($base_dir);
    $self->create_dir;
    $self->create_file;
    Cwd::chdir($self->{cwd});
}

sub create_dir {
    my $self = shift;

    my $dir_list = $self->dir_list;

    foreach my $dir ( @$dir_list ) {
        File::Path::mkpath($dir);
    }
}

sub create_file {
    my $self = shift;

    my $file_list = $self->file_list;

    my $charset = $self->{charset};
    foreach my $file ( @$file_list ) {
        foreach my $filepath ( keys %$file ) {
            open(my $fh, ">:encoding(${charset})", $filepath) or die "$! : $filepath";
            print $fh $file->{$filepath};
            close($fh);
        }
    }
}

sub DESTROY {
    my $self = shift;

    Cwd::chdir($self->{cwd});
}

1;
