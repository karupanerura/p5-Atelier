use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => '__APP_NAME__',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/__APP_NAME__.pm',
    PREREQ_PM     => {
        'Atelier' => '__ATELIER_VERSION__',
    },
    MIN_PERL_VERSION => '__PERL_VERSION__',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
