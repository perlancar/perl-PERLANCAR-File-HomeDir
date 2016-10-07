package PERLANCAR::File::HomeDir;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       get_my_home_dir
               );

our $DIE_ON_FAILURE = 0;

# borrowed from File::HomeDir, with some modifications
sub get_my_home_dir {
    if ($^O eq 'MSWin32') {
        # File::HomeDir always uses exists($ENV{x}) first, does it want to avoid
        # accidentally creating env vars?
        return $ENV{HOME} if $ENV{HOME};
        return $ENV{USERPROFILE} if $ENV{USERPROFILE};
        return join($ENV{HOMEDRIVE}, "\\", $ENV{HOMEPATH})
            if $ENV{HOMEDRIVE} && $ENV{HOMEPATH};
    } else {
        return $ENV{HOME} if $ENV{HOME};
        my @pw;
        eval { @pw = getpwuid($>) };
        return $pw[7] if @pw;
    }

    if ($DIE_ON_FAILURE) {
        die "Can't get home directory";
    } else {
        return undef;
    }
}

1;
# ABSTRACT: Lightweight way to get current user's home directory

=head1 SYNOPSIS

 use PERLANCAR::Home::Dir qw(get_my_home_dir);

 my $dir = get_my_home_dir();


=head1 DESCRIPTION

This is a (temporary?) module to get user's home directory. It is a lightweight
version of L<File::HomeDir> with fewer OS support (only Windows and Unix) and
fewer logic/heuristic.


=head1 VARIABLES

=head2 $DIE_ON_FAILURE => bool (default: 0)

If set to true, will die on failure. Else, function usually return undef on
failure.


=head1 FUNCTIONS

None are exported by default, but they are exportable.

=head2 get_my_home_dir() => str

Try several ways to get home directory. Return undef or die (depends on
C<$DIE_ON_FAILURE>) if everything fails.


=head1 SEE ALSO

L<File::HomeDir>

=cut
