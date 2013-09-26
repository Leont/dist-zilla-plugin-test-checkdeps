package Dist::Zilla::Plugin::Test::CheckDeps;
# vim: set ts=4 sw=4 tw=78 et nolist :

use Moose;
extends qw/Dist::Zilla::Plugin::InlineFiles/;
with qw/Dist::Zilla::Role::TextTemplate Dist::Zilla::Role::PrereqSource/;
use namespace::autoclean;

has fatal => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

has level => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => 'classic',
);


around add_file => sub {
    my ($orig, $self, $file) = @_;

    return $self->$orig(
        Dist::Zilla::File::InMemory->new(
            name    => $file->name,
            content => $self->fill_in_string($file->content,
            {
                dist => \($self->zilla),
                plugin => \$self,
                fatal => $self->fatal,
                level => $self->level,
            })
        )
    );
};

sub register_prereqs {
    my $self = shift;
    $self->zilla->register_prereqs({ phase => 'test' }, 'Test::More' => 0.94, 'Test::CheckDeps' => 0.007);
}

__PACKAGE__->meta->make_immutable;

# ABSTRACT: Check for presence of dependencies

=pod

=head1 SYNOPSIS

 [Test::CheckDeps]
 fatal = 0          ; default
 level = classic

=head1 DESCRIPTION

This module adds a test that assures all dependencies have been installed properly. If requested, it can bail out all testing on error.

If C<fatal> is true, C<BAIL_OUT> is called if the tests fail.

C<level> is passed to C<check_dependencies> in L<Test::CheckDeps>.
(Defaults to C<'classic'>.)

=for Pod::Coverage register_prereqs

=cut

__DATA__
___[ t/00-check-deps.t ]___
use strict;
use warnings;

# this test was generated with {{ ref($plugin) . ' ' . ($plugin->VERSION || '<self>') }}

use Test::More 0.94;
use Test::CheckDeps 0.007;

check_dependencies('{{ $level }}');

if ({{ $fatal }}) {
    BAIL_OUT("Missing dependencies") if !Test::More->builder->is_passing;
}

done_testing;

