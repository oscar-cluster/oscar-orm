package OSCAR::RepoCache;

#
# Copyright (c) 2008 Oak Ridge National Laboratory.
#                    Geoffroy R. Vallee <valleegr@ornl.gov>
#                    All rights reserved.
#
# This file is part of the OSCAR software package.  For license
# information, see the COPYING file in the top level directory of the
# OSCAR source distribution.
#

# This module implements a caching mechanism for the detection of repositories'
# format (yum, apt, and so on). This allows us to avoid getting meta-data files
# from repositories on a very periodical basis which could be problematic if
# the repository admins limits the access to those meta data.
# The "cache" is currently a flat text file: /var/lib/oscar/repoCache.txt, each
# line of the text giving the format of a given repository: <repo_url> <format>
# Of course, a given URL should appear only on time in the cache.

# $Id$

use strict;
use warnings;
use File::Basename;
use File::Path;
use OSCAR::Utils;
use Carp;

use Data::Dumper;

our %cache;

sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = {
        cache_file => '/var/lib/oscar/cache/repoCache.txt',
        cache => undef,
        verbosity => 1,
        @_,
    };
    my $cache_dir = File::Basename::dirname ($self->{cache_file});
    bless ($self, $class);
    if (! -d $cache_dir) {
        print "[INFO] Creating the cache directory\n" if( $self->{verbosity} >= 10 );
        File::Path::mkpath ($cache_dir) 
            or (carp "ERROR: Impossible to create $cache_dir",
                return undef);
    }
    if (-f $self->{cache_file}) {
        if ($self->load_cache ()) {
            carp "ERROR: Impossible to initialize the cache";
            return undef;
        }
    }

    return $self;
}

# Return: 0 if success, -1 else.
sub load_cache ($) {
    my $self = shift;

    open (FILE, $self->{cache_file}) 
        or (carp "ERROR: Impossible to open $self->cache_file", return -1);
    my @lines = <FILE>;
    close (FILE);

    foreach my $line (@lines) {
        next if (!OSCAR::Utils::is_a_valid_string ($line));
        next if (OSCAR::Utils::is_a_comment ($line));
        my ($key, $value) = split (" ", $line);
        $cache{$key} = $value;
    }

    $self->{cache} = \%cache;
    return 0;
}

sub print_cache ($) {
    my $self = shift;

    return 0 if($self->{verbosity} == 0); # Do nothing in quiet mode.

    print "Repositories' format cache:\n";
    if (defined $self->{cache}) {
        my $hash_ref = $self->{cache};
        foreach my $k (keys (%$hash_ref)) {
            print $k . " " . $self->{cache}{$k} . "\n";
        }
    } else {
        print "Cache empty!\n";
    }

    return 0;
}

sub get_format ($$) {
    my ($self, $url) = @_;
    my $format;

    if (defined $self->{cache} > 0) {
#        print "[INFO] Cache existing\n";
        if (!defined $self->{cache}{$url}) {
            require OSCAR::PackageSmart;
            print "[INFO] $url is not in cache\n" if($self->{verbosity} >= 5);
            $format = OSCAR::PackageSmart::detect_pools_format ($url);
            if (!defined ($format)) {
                carp "ERROR: Impossible to detect the format of the $url repo";
                return undef;
            }
            $cache{$url} = $format;
            OSCAR::FileUtils::add_line_to_file_without_duplication (
                "$url $format\n", $self->{cache_file});
        } else {
            print "[INFO] $url is in cache\n" if($self->{verbosity} >= 5);
            return $self->{cache}{$url};
        }
    } else {
        require OSCAR::PackageSmart;
        print "[INFO] Cache empty, populating...\n" if($self->{verbosity} >= 5);
        $format = OSCAR::PackageSmart::detect_pools_format ($url);
        if (!defined ($format)) {
            carp "ERROR: Impossible to detect the format of the $url repo";
            return undef;
        }
        $cache{$url} = $format;
        if (OSCAR::FileUtils::add_line_to_file_without_duplication (
            "$url $format\n", $self->{cache_file})) {
            carp "ERROR: Impossible to add the entry in the cache";
            return undef;
        }
    }

    return $format;
}

sub get_repos_format ($@) {
    my ($self, @repos) = @_;
    my $format;
    my $f;

    foreach my $r (@repos) {
        $f = $self->get_format ($r);
        if (!defined $f) {
            carp "ERROR: Impossible to detect the format of $r";
            return undef;
        }
        $format = $f if (!defined $format);
        if ($format ne $f) {
            carp "ERROR: Conflict in formats ($f, $format)";
            return undef 
        }
    }

    return $format;
}

1;
