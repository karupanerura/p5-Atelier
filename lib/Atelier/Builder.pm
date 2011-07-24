package Atelier::Builder;
use strict;
use warnings;

use 5.10.0;
use Data::Validator;
use File::Spec;
use File::Copy;
use Atelier;

BEGIN {
    srand($$ ^ time);
}

sub new {
    state $rule = Data::Validator->new(
        flavor   => +{ isa => 'Str', default => 'Basic' },
        app_name => +{ isa => 'Str' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    bless(+{ %$args } => $class);
}

sub init {
    my $self = shift;

    $self->{variable} = +{
        APP_NAME        => $self->{app_name},
        ATELIER_VERSION => $Atelier::VERSION,
        PERL_VERSION    => '5.010000'
    };

    my $flavor_dir = $self->flavor_dir;
    my $tmp_dir    = $self->tmp_dir;
    my $dir_callback; $dir_callback = sub{
        my $path = shift;
        my $new_path = $path;

        $new_path =~ s{^${flavor_dir}}{$tmp_dir};

        given ($path) {
            when (-f $_) {
                copy($path, $new_path) or die $!;
            }
            when (-d $_) {
                mkdir($new_path, oct(755));
                $self->dispatch_dir(
                    dir => $path,
                    cb  => $dir_callback,
                );
            }
        }

    };

    $self->dispatch_dir(
        dir => $flavor_dir,
        cb  => $dir_callback,
    );
}

sub variable {
    my $self = shift;
    my $name = shift;

    return "__${name}__" if($name =~ m{^(?:PACKAGE|FILE|LINE|END|DATA)$});

    $self->{variable}{$name} or die(qq{Don't defined tempalte variable "$name".});
}

sub flavor_dir {
    my $self = shift;

    $self->{flavor_dir} ||= "$ENV{HOME}/.atelier/flavor/$self->{flavor}";
}

sub tmp_dir {
    my $self = shift;

    $self->{tmp_dir} ||= do{
        mkdir('/tmp/Atelier',                 oct(755)) unless(-d '/tmp/Atelier');
        mkdir("/tmp/Atelier/$self->{flavor}", oct(755)) unless(-d "/tmp/Atelier/$self->{flavor}");

        my $random;
        do {
            $random = int(rand(1000));
        } while(-d "/tmp/Atelier/$self->{flavor}/$self->{app_name}${random}");
        mkdir("/tmp/Atelier/$self->{flavor}/$self->{app_name}${random}", oct(755));

        "/tmp/Atelier/$self->{flavor}/$self->{app_name}${random}";
    };
}

sub target_dir {
    my $self = shift;

    $self->{target_dir} ||= $self->{app_name};
}

sub build {
    my $self = shift;

    if (-d $self->flavor_dir) {
        $self->init;

        my $file_callback = sub{
            $_[0] =~ s{__(.+?)__}{$self->variable($1)}msxige;
        };
        my $dir_callback; $dir_callback = sub{
            my $path = shift;

            my $path_org = $path;
            if ( $file_callback->($path) ) {
                move($path_org, $path);
            }

            given ($path) {
                when (-f $_) {
                    $self->dispatch_file(
                        file => $path,
                        cb   => $file_callback,
                    );
                }
                when (-d $_) {
                    $self->dispatch_dir(
                        dir => $path,
                        cb  => $dir_callback,
                    );
                }
            }
        };

        $self->dispatch_dir(
            dir => $self->tmp_dir,
            cb  => $dir_callback,
        );
        move($self->tmp_dir, $self->target_dir);
    }
    else {
        require Carp;
        Carp::croak('flavor not found.');
    }
}

sub dispatch_dir {
    state $rule = Data::Validator->new(
        dir => +{ isa => 'Str' },
        cb  => +{ isa => 'CodeRef' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    opendir(my $dir, $args->{dir}) or die "$! : $args->{dir}";
    my @files = readdir($dir);
    closedir($dir);

    foreach my $file (@files) {
        next if($file =~ m{^\.{1,2}$});
        $args->{cb}->(File::Spec->catfile($args->{dir}, $file));
    }
}

sub dispatch_file {
    state $rule = Data::Validator->new(
        file     => +{ isa => 'Str' },
        cb       => +{ isa => 'CodeRef' },
        encoding => +{ isa => 'Str', default => 'utf8' },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    open(my $fh, "<:encoding($args->{encoding})", $args->{file}) or die "$! : $args->{file}";
    my @lines = <$fh>;
    close($fh);

    my $overwrite;
    foreach(@lines) {
        my $defalt = $_;
        $args->{cb}->($_);
        $overwrite ||= ($defalt ne $_);
    }

    if ($overwrite) {
        open(my $fh, ">:encoding($args->{encoding})", $args->{file}) or die "$! : $args->{file}";
        foreach my $line (@lines) {
            print $fh ($line);
        }
        close($fh);
    }
}

sub DESTROY {
    my $self = shift;
    return unless(-d $self->tmp_dir);

    my $dir_callback; $dir_callback = sub{
        my $path = shift;

        given ($path) {
            when (-f $_) {
                unlink($path);
            }
            when (-d $_) {
                $self->dispatch_dir(
                    dir => $path,
                    cb  => $dir_callback,
                );
            }
        }

    };

    $self->dispatch_dir(
        dir => $self->tmp_dir,
        cb  => $dir_callback,
    );
    rmdir($self->tmp_dir);
}

1;
