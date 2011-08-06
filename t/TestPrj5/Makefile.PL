use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'TestPrj5',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/TestPrj5.pm',
    PREREQ_PM     => {
        'Atelier' => '0.02',
    },
    MIN_PERL_VERSION => '5.010_000',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
