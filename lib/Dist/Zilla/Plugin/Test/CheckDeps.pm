package Dist::Zilla::Plugin::Test::CheckDeps;

use Moose;
extends qw/Dist::Zilla::Plugin::InlineFiles/;
with qw/Dist::Zilla::Role::TextTemplate/;

has fatal => (
	is => 'ro',
	isa => 'Bool',
	default => 0,
);

around add_file => sub {
    my ($orig, $self, $file) = @_;
    return $self->$orig(
        Dist::Zilla::File::InMemory->new(
            name    => $file->name,
            content => $self->fill_in_string($file->content, { fatal => $self->fatal })
        ),
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__DATA__
___[ t/00-assure-deps.t ]___
use CPAN::Meta;
use List::Util qw/first/;
use Module::Metadata;
use Test::More 0.88;

sub check_dependencies {
	my ($meta, $phase, $type) = @_;

	my $reqs = $meta->effective_prereqs->requirements_for($phase, $type);
	for my $module ($reqs->required_modules) {
		my $version;
		if ($module eq 'perl') {
			$version = $];
		}
		else {
			my $metadata = Module::Metadata->new_from_module($module);
			fail("Module '$module' is not installed"), next if not defined $metadata;
			$version = eval { $metadata->version };
		}
		fail("Missing version info for module '$module'"), next if not $version;
		fail(sprintf 'Version %s of module %s is not in range \'%s\'', $version, $module, $reqs->as_string_hash->{$module}), next if not $reqs->accepts_module($module, $version);
		pass "$module $version is present";
	}
}

my $metafile = first { -e $_ } qw/MYMETA.json MYMETA.yml META.json META.yml/ or BAIL_OUT("No META information provided\n");
my $meta = CPAN::Meta->load_file($metafile);

check_dependencies($meta, $_, 'requires') for qw/configure build runtime/;

if ({{ $fatal }}) {
	BAIL_OUT("Missing dependencies") if !Test::More->builder->is_passing;
}

done_testing;

__END__

#ABSTRACT: Check for presence of dependencies

=head1 SYNOPSIS

 [Test::AssureDeps]
 fatal = 0 ; default

=head1 DESCRIPTION

This module adds a test that assures all dependencies have been installed properly. If requested, it can bail out all testing on error.

