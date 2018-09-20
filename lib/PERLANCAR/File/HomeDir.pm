package PERLANCAR::File::HomeDir;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       get_my_home_dir
                       get_user_home_dir
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

# borrowed from File::HomeDir, with some modifications
sub get_user_home_dir {
    my ($name) = @_;

    if ($^O eq 'MSWin32') {
        # not yet implemented
        return undef;
    } else {
        # IF and only if we have getpwuid support, and the name of the user is
        # our own, shortcut to my_home. This is needed to handle HOME
        # environment settings.
        if ($name eq getpwuid($<)) {
            return get_my_home_dir();
        }

      SCOPE: {
            my $home = (getpwnam($name))[7];
            return $home if $home and -d $home;
        }

        return undef;
    }

}

1;
# ABSTRACT: Lightweight way to get current user's home directory

=head1 SYNOPSIS

 use PERLANCAR::File::HomeDir qw(get_my_home_dir get_user_home_dir);

 my $dir = get_my_home_dir(); # e.g. "/home/ujang"

 $dir = get_user_home_dir("ujang");


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

=head2 get_my_home_dir

Usage:

 my $home_dir = get_my_home_dir();

Try several ways to get home directory of the current user. Return undef or die
(depends on C<$DIE_ON_FAILURE>) if everything fails.

=head2 get_user_home_dir

Usage:

 my $home_dir = get_user_home_dir($username);

Try several ways to get home directory of a specified user (C<$username>).


=head1 SEE ALSO

L<File::HomeDir>

=cut
