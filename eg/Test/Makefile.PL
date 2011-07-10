use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Test',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/Test.pm',
    PREREQ_PM     => {
        'Atelier' => '0.01',
    },
    MIN_PERL_VERSION => '5.010000',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
