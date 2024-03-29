package OSCAR::RepositoryManager;

#
# Copyright (c) 2008 Oak Ridge National Laboratory.
#                    Geoffroy R. Vallee <valleegr@ornl.gov>
#                    All rights reserved.
#
# This file is part of the OSCAR software package.  For license
# information, see the COPYING file in the top level directory of the
# OSCAR source distribution.
#

# $Id$

use strict;
use warnings;
use OSCAR::OCA::OS_Detect;
use File::Basename;
use Carp;

sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = { 
        repos => undef,
        distro => undef,
        format => undef,
        repo_cache => undef,
        pm => undef,
	verbosity => 0,
        @_,
    };
    bless ($self, $class);
    if (!defined ($self->{repos})
        && !defined ($self->{distro})
        && !defined ($self->{pm})) {
        die "ERROR: Invalid object, the initialization is most certainly ".
            "incorrect, please read the documentation for more information ".
            "(perldoc OSCAR::RepositoryManager)";
    }
    if (!defined ($self->{repos}) && defined ($self->{distro})) {
        require OSCAR::PackagePath;
        my ($dist, $ver, $arch) 
            = OSCAR::PackagePath::decompose_distro_id ($self->{distro});
        my $os = OSCAR::OCA::OS_Detect::open (fake=>
            {distro=>$dist, distro_version=>$ver, arch=>$arch});
        my $drepo = OSCAR::PackagePath::distro_repo_url(os=>$os);
        my $orepo = OSCAR::PackagePath::oscar_repo_url(os=>$os);
        if ($drepo ne "" and !OSCAR::Utils::is_a_valid_string ($drepo)) {
            die "ERROR: Impossible to get the distro repo(s) for ".
                $self->{distro};
	}
        if (!OSCAR::Utils::is_a_valid_string ($orepo)) {
            die "ERROR: Impossible to get the oscar repo for ".
                $self->{distro};
        }
        $self->{repos} = "$orepo";
        $self->{repos} = "$drepo,$orepo" if $drepo ne "";
    }
    # Note that the cache for repositories' format should be initialized before
    # PackMan
    if (!defined ($self->{repo_cache})) {
        require OSCAR::RepoCache;
	$self->{repo_cache} = OSCAR::RepoCache->new( verbosity => $self->{verbosity});
    }
    if (!defined ($self->{pm})) {
        if ($self->create_packman_object ($self->{repo_cache})) {
            die "ERROR: Impossible to associate a PackMan object";
        }
    }

    return $self;
}

sub set_verbosity ($$) {
    my $self = shift;
    my $verbosity = shift;
    die "ERROR: undefined vermovity." if(! defined $verbosity);
    if ($verbosity >= 0 && $verbosity <= 10) {
        $self->{verbosity} = $verbosity;
    } else {
        warn "verbosity must be within 0..10 range. Assuming verbosity=10.";
	$self->{verbosity} = 10;
    }
}

# Returns the list of repos for the current object. In order of preference:
#   - repos that have been specified manually during initialization,
#   - repos associated to the packman object specified during initialization
sub get_repos ($) {
    my $self = shift;

    if (defined ($self->{repos})) {
        return ($self->{repos});
    }

    if (defined ($self->{distro})) {
        require OSCAR::PackagePath;
        my ($dist, $ver, $arch) 
            = OSCAR::PackagePath::decompose_distro_id ($self->{distro});
        my $os = OSCAR::OCA::OS_Detect::open (fake=>
            {distro=>$dist, version=>$ver, arch=>$arch});
        my $drepo = OSCAR::PackagePath::distro_repo_url(os=>$os);
        my $orepo = OSCAR::PackagePath::oscar_repo_url(os=>$os);
        $self->{repos} = "$drepo,$orepo";
        return $self->{repos};
    }

    return undef;
}

################################################################################
# Create a packman object from basic info available. We typically have two     #
# cases:                                                                       #
# (i) we know the distro, from there, we know everything about the repos we    #
# need to use and the binary format used underneath (deb vs. rpm), we create   #
# the PackMan object from there;                                               #
# (ii) we have a list of repos, in that case, we can detect the format and     #
# instanciate the PackMan object.                                              #
#                                                                              #
# Input: None.                                                                 #
# Return: 0 if success, -1 else.                                               #
################################################################################
sub create_packman_object ($$) {
    my ($self, $rc) = @_;

    if (!defined $self->{repos}) {
        carp "ERROR: This is bad, no repos are defined, this should never ".
             "happen" . status();
        return -1;
    }

    my @repos = split (",", $self->{repos});
    if (scalar (@repos) == 0) {
        carp "ERROR: Impossible to get the repositories";
        return -1;
    }
    if (!defined $rc) {
        carp "ERROR: Impossible to initialize the cache for repositories";
        return -1;
    }
    my $format = $rc->get_repos_format (@repos);
    if (!defined ($format)) {
        carp "ERROR: Impossible to detect the binary format (" .
             join (", ", @repos).")";
        return -1;
    }
    $self->{format} = $format;
    if ($format eq "deb") {
        require OSCAR::PackMan;
        $self->{pm} = OSCAR::PackMan::DEB->new;
        if (!defined $self->{pm}) {
            carp "ERROR: Impossible to create a PackMan object";
            return -1;
        }
    } elsif ($format eq "rpm") {
        require OSCAR::PackMan;
        $self->{pm} = OSCAR::PackMan::RPM->new;
        if (!defined $self->{pm}) {
            carp "ERROR: Impossible to create a PackMan object";
            return -1;
        }
    } else {
        carp "ERROR: Impossible to get the repo format";
        return -1;
    }
    $self->{pm}->repo (@repos);
    my $ret = $self->{pm}->distro ($self->{distro}) if (defined $self->{distro});
    if ($ret != 1) {
        carp "ERROR: Cannot detect the distro";
        return -1;
    }

    return 0;
}

################################################################################
# Search about packages.                                                       #
#                                                                              #
# Input: pattern, pattern to use for the search.                               #
# Return: return from PackMan->search->repo().                                 #
################################################################################
sub search_opkgs ($$) {
    my ($self, $pattern) = @_;

    return ($self->{pm}->search_repo ($pattern));
}

################################################################################
# Show details about OPKGs.                                                    #
#                                                                              #
# Input: opkg, a string representing the list of OPKGs (space between each     #
#              name).                                                          #
# Return: return from PackMan->show().                                         #
################################################################################
sub show_opkg ($$) {
    my ($self, $opkg) = @_;

    return $self->{pm}->show_repo ($opkg);
}

################################################################################
# Install a list of packages based on current ORM data.                        #
#                                                                              #
# Input: dest, where you want to install the package (chroot for instance),    #
#              undef if you want to install the packages on the local system.  #
# Return: return from PackMan->smart_install().                                #
# TODO: switching to a ref to an array for the list of OPKGs will limit the    #
#       possibility of bugs, because of parameters shifting.                   #
################################################################################
sub install_pkg ($$@) {
    my ($self, $dest, @pkgs) = @_;

    my $dest_msg = "on system";
    $dest_msg = "in image $dest" if ($dest ne '/');

    if (!defined $dest || ! -d File::Basename::dirname ($dest)) {
        carp "ERROR: Invalid destination ($dest), can't install packages";
        return undef;
    }
    print "Installing packages $dest_msg: " . join(" ",@pkgs) . "\n"
        if ($self->{verbosity} >= 1);

    $self->{pm}->chroot($dest);

    print $self->status() if ($self->{verbosity} >= 10);

    return $self->{pm}->smart_install (@pkgs);
}

sub remove_pkg ($$@) {
    my ($self, $dest, @pkgs) = @_;

    my $dest_msg = "system";
    $dest_msg = "image $dest" if ($dest ne '/');

    if (!defined $dest || ! -d File::Basename::dirname ($dest)) {
        carp "ERROR: Invalid destination ($dest), can't remove packages";
        return undef;
    }
    print "Removing packages from $dest_msg: " . join(" ",@pkgs) . "\n"
        if ($self->{verbosity} >= 1);

    $self->{pm}->chroot($dest);

    print $self->status() if ($self->{verbosity} >= 10);

    return $self->{pm}->smart_remove (@pkgs);
}    

################################################################################
# Gives the status of the current RepositoryManager object,                    #
#                                                                              #
# Input: none.                                                                 #
# Return: a string representing the status, undef if error.                    #
################################################################################
sub status ($) {
    my $self = shift;
    my $status = "Repository Manager Status:\n";
    $status .= "\tRepos: ".$self->{repos}."\n" if (defined $self->{repos});
    $status .= "\tDistro: ".$self->{distro}."\n" if (defined $self->{distro});
    $status .= "\tFormat: ".$self->{format}."\n" if (defined $self->{format});
    $status .= $self->{pm}->status() if (defined $self->{pm});
    return $status;
}


1;

__END__

=head1 DESCRIPTION

=head2 Creation of a new RepositoryManager object

require OSCAR::RepositoryManager;
my $rm = OSCAR::RepositoryManager->new (distro=>$distro);

If the creation fails, $rm is equal to undef.

=head2 Searching for OPKGs

my ($rc, @output) = $rm->search_opkgs ($search);

where:

- search is the pattern you are looking for

- rc is the return code

- output is the result (i.e., list of OPKGs)

=head2 Showing details about a specific OPKG

my ($rc, %output) = $rm->show_opkg ($opkg);

- opkg is the name of the binary package associated to the OPKG; for instance
for ODA, three binary packages are available: opkg-oda-server, opkg-oda-client,
and opkg-oda. There is no generic way of querying the details about a given
OPKGs based on the meta-name of the OPKG (i.e., oda with our example).

- rc is the return code of the query.

- output is a hash with all available details about the OPKG

=head2 Install Packages

my ($rc, @output) = install_pkg ("/", "yume");

=head2 Remove Packages

my ($rc, @output) = remove_pkg ("/", "yume");

=head1 EXAMPLES

my ($rc, @output) = $rm->search_opkgs ("^opkg-.*-server$"); will give you the
list of all available OPKGs (note that the command will give the list of binary
packages for the server side of OSCAR; there is not simple way to get directly
the list of OPKGs).

=head1 AUTHOR

Geoffroy Vallee, Oak Ridge National Laboratory

=head1 SEE ALSO

perl(1), perldoc OSCAR::PackMan

=cut
