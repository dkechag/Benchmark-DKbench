#!/usr/bin/env perl

use strict;
use warnings;

# Assumes you have at least tar/gunzip and cpanm installed.

use File::Fetch;

unless (-f "data/gbbct5.seq") {
    print "Fetching gbbct5.seq from Genbank release 213...\n";
    my $ff = File::Fetch->new(uri => 'https://ecuadors.net/files/gbbct5.seq.gz');
    my $where = $ff->fetch( to => 'data/' ) or die $ff->error;
}

print "Unzipping data files...\n";
system "gunzip data/*.gz";

print "Installing reference cpan verions (with --force)...\n";
system "cpanm -f http://cpan.metacpan.org/authors/id/O/OA/OALDERS/HTML-Parser-3.76.tar.gz";
system "cpanm -f http://cpan.metacpan.org/authors/id/K/KE/KENTNL/HTML-Tree-5.07.tar.gz";
system "cpanm -f http://cpan.metacpan.org/authors/id/N/NI/NIGELM/HTML-Formatter-2.16.tar.gz";
system "cpanm -f http://cpan.metacpan.org/authors/id/K/KA/KAMELKEV/CSS-Inliner-4014.tar.gz";
system "cpanm -f http://cpan.metacpan.org/authors/id/C/CJ/CJFIELDS/BioPerl-1.7.8.tar.gz";
system "cpanm -f https://cpan.metacpan.org/authors/id/E/ET/ETHER/Moose-2.2201.tar.gz";
system "cpanm Astro::Coord::Constellations Test::Harness";
