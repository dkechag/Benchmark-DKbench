#!/usr/bin/env perl

use strict;
use warnings;

# Assumes you have at least tar/gunzip, File::Fetch and cpanm installed
# (e.g. yum install perl-App-cpanminus for CentOS 7, apt install cpanminus
# for Debian buster). Any true argument uses sudo for cpanm commands.
# In some systems you might need to install some modules (XML etc) with the
# package manager (e.g. yum install perl-XML-LibXML perl-XML-Parser for CentOS,
# apt install libxml-simple-perl for Debian buster)

use File::Fetch;

my $sudo = $ARGV[0] ? 'sudo' : '';

unless (-f "data/gbbct5.seq" || -f "data/gbbct5.seq.gz") {
    print "Fetching gbbct5.seq of Genbank release 213...\n";
    my $ff = File::Fetch->new(uri => 'http://ecuadors.net/files/gbbct5.seq.gz');
    my $where = $ff->fetch( to => 'data/' ) or die $ff->error;
}

print "Unzipping data files...\n";
system "gunzip data/*.gz";
system "cd data && tar xvf t.tar && rm t.tar";

my @packages = qw#
http://cpan.metacpan.org/authors/id/O/OA/OALDERS/HTML-Parser-3.76.tar.gz
http://cpan.metacpan.org/authors/id/K/KE/KENTNL/HTML-Tree-5.07.tar.gz
http://cpan.metacpan.org/authors/id/N/NI/NIGELM/HTML-Formatter-2.16.tar.gz
http://cpan.metacpan.org/authors/id/K/KA/KAMELKEV/CSS-Inliner-4014.tar.gz
http://cpan.metacpan.org/authors/id/C/CJ/CJFIELDS/BioPerl-1.7.8.tar.gz
http://cpan.metacpan.org/authors/id/E/ET/ETHER/Moose-2.2201.tar.gz
http://cpan.metacpan.org/authors/id/D/DR/DROLSKY/DateTime-TimeZone-2.51.tar.gz
http://cpan.metacpan.org/authors/id/D/DR/DROLSKY/DateTime-1.54.tar.gz
http://cpan.metacpan.org/authors/id/D/DK/DKECHAG/Astro-Coord-Precession-0.03.tar.gz
http://cpan.metacpan.org/authors/id/D/DK/DKECHAG/Astro-Coord-Constellations-0.01.tar.gz
http://cpan.metacpan.org/authors/id/D/DK/DKECHAG/Math-DCT-0.04.tar.gz
#;

print "Installing reference cpan verions (with --force)...\n";
system "$sudo cpanm -f -n $_" foreach @packages;
system "$sudo cpanm -n MCE::Loop Test::Harness Test::Requires";
