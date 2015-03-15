use strict;
use warnings;

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
            path(qw(source lib Foo.pm)) => "package Foo; 1;\n",
        },
    },
);

$tzil->chrome->logger->set_debug(1);
$tzil->build;

my $build_dir = $tzil->tempdir->subdir('build');
ok(!-e path($build_dir, 't', '00-check-deps.t'), 'default test not created');
ok(-e path($build_dir, 't', 'foo.t'), 'test created using new name');

diag 'got log messages: ', explain $tzil->log_messages
    if not Test::Builder->new->is_passing;

done_testing;
