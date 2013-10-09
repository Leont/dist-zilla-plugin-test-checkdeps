use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::Deep;
use Test::Deep::JSON;
use Test::DZil;
use Path::Tiny;
use Cwd;

BEGIN {
    use Dist::Zilla::Plugin::Test::CheckDeps;
    $Dist::Zilla::Plugin::Test::CheckDeps::VERSION = 9999
        unless $Dist::Zilla::Plugin::Test::CheckDeps::VERSION;
}


# build fake dist
my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            'source/dist.ini' => simple_ini(
                [ Prereqs => RuntimeRequires => { strict => 0 } ],
                [ MetaJSON => ],
                [ 'Test::CheckDeps' => { level => 'suggests' } ],
            ),
            path(qw(source lib Foo.pm)) => "package Foo; 1;",
        },
    },
);
$tzil->build;

my $build_dir = $tzil->tempdir->subdir('build');
my $file = path($build_dir, 't', '00-check-deps.t');
ok( -e $file, 'test created');

my $content = $file->slurp;
unlike($content, qr/[^\S\n]\n/m, 'no trailing whitespace in generated test');

like($content, qr/^use Test::CheckDeps [\d.]+;$/m, 'use line is correct');

my $json = $tzil->slurp_file('build/META.json');
cmp_deeply(
    $json,
    json(superhashof({
        prereqs => superhashof({
                test => {
                    requires => {
                        'Test::More' => '0.94',
                        'Test::CheckDeps' => '0.010',
                    },
                },
            }),
        }),
    ),
    'test prereqs are properly injected',
);

my $cwd = getcwd;
my $prereqs_tested;
subtest 'run the generated test' => sub
{
    chdir $build_dir;

    do $file;
    warn $@ if $@;

    $prereqs_tested = Test::Builder->new->current_test;
};

# Test::More, Test::CheckDeps, strict
is($prereqs_tested, 3, 'correct number of prereqs were tested');

chdir $cwd;

done_testing;
