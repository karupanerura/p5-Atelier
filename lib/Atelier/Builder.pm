package Atelier::Builder;
use strict;
use warnings;

use 5.10.0;
use Data::Validator;
use Fcntl ':flock';
use File::Path;
use File::Copy;
use File::Find;
use Module::Load;
use Module::Find;
use Atelier;
use Atelier::Util::TinyTemplate;
use Data::Dumper;

BEGIN {
    srand($$ ^ time);
}

sub new {
    state $rule = Data::Validator->new(
        flavor    => +{ isa => 'Str', default => 'Basic' },
        app_name  => +{ isa => 'Str' },
        charset   => +{ isa => 'Str', default => 'utf8' },
        variables => +{ isa => 'HashRef', optional => 1 },
    )->with('Method');
    my($class, $args) = $rule->validate(@_);

    bless(+{ %$args } => $class);
}

sub init {
    my $self = shift;

    $self->{variables} ||= +{
        APP_NAME        => $self->{app_name},
        ATELIER_VERSION => $Atelier::VERSION,
        PERL_VERSION    => '5.010_000'
    };

    my $flavor_dir = $self->flavor_dir;
    my $tmp_dir    = $self->tmp_dir;
    find(+{
        wanted => sub {
            my $path = $File::Find::name;
            my $new_path = $path;

            $new_path =~ s{^${flavor_dir}}{$tmp_dir};

            if (-f $path) {
                copy($path, $new_path) or die $!;
            }
            elsif (-d $path) {
                mkdir($new_path, oct(755));
            }
        },
        no_chdir => 1,
    }, $flavor_dir);
}

sub flavor_dir {
    my $self = shift;

    $self->{flavor_dir} ||= "$ENV{HOME}/.atelier/flavor/$self->{flavor}";
}

sub flavor_version {
    my $self = shift;

    $self->flavor_info->{$self->{flavor}}{VERSION} || 0;
}

sub flavor_info {
    my $self = shift;

    $self->{flavor_info} ||= eval { do("$ENV{HOME}/.atelier/flavor_info.pl") } || do {
        open(my $fh, '>', "$ENV{HOME}/.atelier/flavor_info.pl");
        print $fh '+{};';
        close($fh);

        +{};
    };
}

sub write_flavor_info {
    my $self = shift;
    my $flavor_class = shift;

    my $flavor_info = $self->flavor_info;
    {
        no strict 'refs';
        $flavor_info->{$self->{flavor}}{VERSION} = ${"${flavor_class}::VERSION"} || 0;
    }
    my $data = Dumper($flavor_info);
    $data =~ s/^\$VAR1 =//;

    open(my $fh, '>', "$ENV{HOME}/.atelier/flavor_info.pl");
    print $fh "$data";
    close($fh);
}

sub is_fresh_flavor_class {
    my $self = shift;
    my $flavor_class = "Atelier::Flavor::$self->{flavor}";
    load($flavor_class);

    {
        no strict 'refs';
        ($self->flavor_version < (${"${flavor_class}::VERSION"} || 0));
    } 
}

sub tmp_dir {
    my $self = shift;

    $self->{tmp_dir} ||= do{
        my $random;
        do {
            $random = int(rand(1000));
        } while(-d "/tmp/Atelier/$self->{flavor}/$self->{app_name}${random}");
        File::Path::mkpath("/tmp/Atelier/$self->{flavor}/$self->{app_name}${random}");

        "/tmp/Atelier/$self->{flavor}/$self->{app_name}${random}";
    };
}

sub target_dir {
    my $self = shift;

    $self->{target_dir} ||= $self->{app_name};
}

sub build {
    my $self = shift;

    if(not(-d $self->flavor_dir) or $self->is_fresh_flavor_class) {
        my $flavor_class = "Atelier::Flavor::$self->{flavor}";
        load($flavor_class);

        $flavor_class->new(
            charset => $self->{charset}
        )->create;
        $self->write_flavor_info($flavor_class);
    }

    $self->init;

    find(+{
        wanted => sub{
            my $path = $File::Find::name;

            if (-f $path) {
                open(my $in, "<:encoding($self->{charset})", $path) or die qq{Can't open file "$path": $!};
                flock($in, LOCK_EX);
                my $template = join('', <$in>);
                flock($in, LOCK_UN);
                close($in);

                my $result = Atelier::Util::TinyTemplate->render_string(
                    template  => $template,
                    variables => $self->{variables},
                );

                open(my $out, ">:encoding($self->{charset})", $path) or die qq{Can't open file "$path": $!};
                flock($out, LOCK_EX);
                
                print $out $result;

                flock($out, LOCK_UN);
                close($out);
            }
        },
        no_chdir => 1,
    }, $self->tmp_dir);
    finddepth(+{
        wanted => sub{
            my $path = $File::Find::name;

            my $new_path = Atelier::Util::TinyTemplate->render_string(
                template  => $path,
                variables => $self->{variables},
            );

            move($path, $new_path) if($path ne $new_path);
        },
        no_chdir => 1,
    }, $self->tmp_dir);

    move($self->tmp_dir, $self->target_dir);
}

sub DESTROY {
    my $self = shift;
    return unless(-d $self->tmp_dir);

    File::Path::rmtree($self->tmp_dir);
}

1;
