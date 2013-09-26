# NAME

Dist::Zilla::Plugin::Test::CheckDeps - Check for presence of dependencies

# VERSION

version 0.009

# SYNOPSIS

    [Test::CheckDeps]
    fatal = 0          ; default
    level = classic

# DESCRIPTION

This module adds a test that assures all dependencies have been installed properly. If requested, it can bail out all testing on error.

This plugin accepts the following options:

- `fatal`: if true, `BAIL_OUT` is called if the tests fail. Defaults
to false.
- `level`: passed to `check_dependencies` in [Test::CheckDeps](http://search.cpan.org/perldoc?Test::CheckDeps).
(Defaults to `classic`.)
- `filename`: the name of the generated file. Defaults to
`t/00-check-deps.t`.

# AUTHOR

Leon Timmermans <leont@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Leon Timmermans.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# CONTRIBUTORS

- Karen Etheridge <ether@cpan.org>
- Leon Timmermans <fawaka@gmail.com>
