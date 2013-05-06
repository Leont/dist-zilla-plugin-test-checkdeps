package Dist::Zilla::Plugin::Test::CheckDeps;

use Moose;
extends qw/Dist::Zilla::Plugin::InlineFiles/;
with qw/Dist::Zilla::Role::TextTemplate Dist::Zilla::Role::PrereqSource/;

has fatal => (
	is => 'ro',
	isa => 'Bool',
	default => 0,
);

sub mvp_multivalue_args { qw(also) }

has also => (
        is => 'ro',
        isa => 'ArrayRef',
        lazy => 1,
        default => sub { [] },
);

around add_file => sub {
	my ($orig, $self, $file) = @_;

        my $extra_tests = '';

        if (my @also = @{$self->also})
        {
            my %also = map { split(' ', $_, 2) } @also;

            $extra_tests = '
use List::Util qw/first/;
use Module::Metadata;
use Test::CheckDeps qw/check_dependencies_opts/;

TODO: {
if (my $metafile = first { -e $_ } qw(MYMETA.json MYMETA.yml META.json META.yml))
{
    my $meta = CPAN::Meta->load_file($metafile);
';

            foreach my $phase (keys %also)
            {
                my $type = $also{$phase};
                $extra_tests .= "
    local \$TODO = '$phase $type';
    check_dependencies_opts(\$meta, '$phase', '$type');
";
            }
            $extra_tests .= "}\n}\n";
        }

	return $self->$orig(
		Dist::Zilla::File::InMemory->new(
			name    => $file->name,
			content => $self->fill_in_string(
                            $file->content,
                            {
                                fatal => $self->fatal,
                                extra_tests => $extra_tests,
                            },
                        )
		)
	);
};

sub register_prereqs {
	my $self = shift;
	$self->zilla->register_prereqs({ phase => 'test' }, 'Test::More' => 0.88, 'Test::CheckDeps' => 0.002);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

#ABSTRACT: Check for presence of dependencies

=head1 SYNOPSIS

 [Test::CheckDeps]
 fatal = 0 ; default

=head1 DESCRIPTION

This module adds a test that assures all dependencies have been installed properly. If requested, it can bail out all testing on error.

Additional phases and types can be tested as TODO tests via the C<also> option:

 [Test::CheckDeps]
 also = runtime recommends
 also = test recommends

=for Pod::Coverage
register_prereqs
=end

=cut

__DATA__
___[ t/00-check-deps.t ]___
use Test::More 0.94;
use Test::CheckDeps 0.002;

check_dependencies();

if ({{ $fatal }}) {
    BAIL_OUT("Missing dependencies") if !Test::More->builder->is_passing;
}

{{ $extra_tests }}

done_testing;

