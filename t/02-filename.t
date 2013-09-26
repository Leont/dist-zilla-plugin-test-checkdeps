use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::DZil;
use Path::Tiny;

my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            'source/dist.ini' => simple_ini(
                [ GatherDir => ],
                [ 'Test::CheckDeps' => { filename => 't/foo.t' } ],
            ),
            path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
        },
    },
);

$tzil->build;

my $build_dir = $tzil->tempdir->subdir('build');
ok(!-e path($build_dir, 't', '00-check-deps.t'), 'default test not created');
ok(-e path($build_dir, 't', 'foo.t'), 'test created using new name');

done_testing;
