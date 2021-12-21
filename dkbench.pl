#!/usr/bin/env perl

BEGIN {
    use Time::HiRes;
    my $start = Time::HiRes::time();
}

use strict;
use warnings;

use lib 'lib';

use Digest;
use Getopt::Long;

use Astro::Coord::Constellations 'constellation_for_eq';
use Astro::Coord::Precession 'precess';
use CSS::Inliner;
use DKBench::Prime;
use HTML::FormatText;
use HTML::TreeBuilder;
use Math::DCT ':all';

my $VERSION = '1.0';

GetOptions (
    skip_bio   => \my $skip_bio,
    skip_moose => \my $skip_moose,
    skip_dt    => \my $skip_dt
);

print "DKBench v$VERSION\n";
print "Perl version $^V\n";
version_warnings();
srand(1); # For repeatability

my $start = time();

my %benchmarks = (
    'Astro'  => sub { bench_astro(100_000) },
    'BioPerl Codons' => sub { bench_bioperl_codons(1,5) },
    'BioPerl Monomers' => sub { bench_bioperl_mono(500) },
    'CSS::Inliner' => sub { bench_css(10) },
    'DateTime' => sub { bench_datetime(10000) },
    'Digest' => sub { bench_digest(500) },
    'HTML::FormatText' => sub { bench_formattext(10) },
    'Math::DCT' => sub { bench_dct(1000000, 8); bench_dct(50000, 32) },
    'Moose' => sub { bench_moose(30000) },
    'Primes' => sub { bench_primes(5, 10_000_000) },
    'Regex/Replace' => sub { bench_regex_repl(25) },
    'Regex/Replace utf8' => sub { bench_regex_repl(25, 'utf8') },
    'Test Moose' => sub { bench_moose_tests(1) },
);

print pad_to("Test").pad_to("Time (sec)")."Last run result\n";

foreach my $bench (sort keys %benchmarks) {
    next if $skip_bio  && $bench =~ /BioPerl/;
    next if $skip_moose  && $bench =~ /Moose/;
    next if $skip_dt  && $bench =~ /DateTime/;
    my $t_start = Time::HiRes::time();
    my $res     = $benchmarks{$bench}->();
    my $time    = sprintf("%.3f", Time::HiRes::time()-$t_start);
    print pad_to("$bench:").pad_to($time)."$res\n";
}

printf pad_to("Total time:")."%.2f\n", Time::HiRes::time()-$start;

sub version_warnings {
    warn "! Perl version v5.32.1 recommended as a comparison base\n"
        unless $^V eq 'v5.32.1';

    my %mod_ver = (
        Moose                      => 2.2201,
        DateTime                   => 1.54,
        'DateTime::TimeZone'       => 2.51,
        'Bio::SeqIO'               => '1.7.8',
        'Bio::Tools::SeqStats'     => '1.7.8',
        'HTML::Parser'             => 3.76,
        'HTML::FormatText'         => 2.16,
        'HTML::TreeBuilder'        => 5.07,
        'CSS::Inliner'             => 4014
    );

    foreach my $module (sort keys %mod_ver) {
        next if $skip_bio  && $module =~ /Bio::/;
        next if $skip_moose  && $module =~ /Moose/;
        next if $skip_dt  && $module =~ /DateTime/;
        eval "use $module";
        my $ver = eval "\$${module}::VERSION" || 'none';
        warn "! $module $mod_ver{$module} recommended as a comparison base ($ver found)\n"
            unless $ver eq $mod_ver{$module};
    }
}

sub bench_digest {
    my $iter = shift;
    my $str  = read_wiki_files('');
    my $hex;
    foreach (1..$iter) {
        my $d = Digest->new("MD5");
        $d->add($str, $str);
        $hex = $d->hexdigest;
        $d = Digest->new("SHA-512");
        $d->add($str);
        $hex = $d->hexdigest;
        $d = Digest->new("SHA-1");
        $d->add($str);
        $hex = $d->hexdigest;
    }
    return $hex;
}

sub bench_primes {
    my $iter = shift;
    my $max  = shift;
    my @primes;
    @primes = DKBench::Prime::get_primes($max) for (1..$iter);
    return scalar(@primes)." primes up to $max";
}

sub bench_astro {
    my $iter = shift;
    my $precessed = precess([rand(24), rand(180)-90], rand(200)+1900, rand(200)+1900)
        for (1..$iter*10);
    my $constellation_abbrev;
    $constellation_abbrev = constellation_for_eq(rand(24), rand(180)-90, rand(200)+1900)
        for (1..$iter);
    return "Constellation: $constellation_abbrev";    
}

sub bench_dct {
    my $iter = shift;
    my $sz   = shift;
    my @arrays;
    my $dct;
    push @arrays, [map { rand(256) } ( 1..$sz*$sz )] foreach 1..10;
    $dct = dct2d($arrays[$iter % 10], $sz) foreach 1..$iter;
    return "0,0: $dct->[0]";
}

sub array2d {
    my $sz = shift;
    my @array;
    foreach my $x (1..$sz) {
        push @array, map { rand(256) } ( 1..$sz );
    }
    return \@array;
}

sub bench_bioperl_mono {
    my $iter = shift;
    my $in = Bio::SeqIO->new(-file => "data/gbbct5.seq", -format => "genbank");
    my $builder = $in->sequence_builder();
    $builder->want_none();
    $builder->add_wanted_slot('display_id','seq');
    my $monomer_ref;
    for (1..$iter) {
        my $seq = $in->next_seq;
        my $seq_stats = Bio::Tools::SeqStats->new($seq);
        my $weight = $seq_stats->get_mol_wt();
        $monomer_ref = $seq_stats->count_monomers();
    }
    my $cnt;
    $cnt += $monomer_ref->{$_} for keys %$monomer_ref;
    return "$cnt monomers";
}

sub bench_bioperl_codons {
    my $iter = shift;
    my $skip = shift;
    my $codon_ref;
    foreach (1..$iter) {
        my $in = Bio::SeqIO->new(-file => "data/gbbct5.seq", -format => "genbank");
        $in->next_seq for (1..$skip);
        my $seq = $in->next_seq;
        my $seq_stats = Bio::Tools::SeqStats->new($seq);
        $codon_ref = $seq_stats->count_codons();
    }
    my $cnt;
    $cnt += $codon_ref->{$_} for keys %$codon_ref;
    return "$cnt codons";
}

sub bench_formattext {
    my $iter = shift;
    my $file;
    my $text;
    for (0..$iter-1) {
        my $i = $_ % 2;
        $file = "data/wiki$i.html";
        my $tree = HTML::TreeBuilder->new->parse_file($file);
        my $formatter = HTML::FormatText->new();
        $text = $formatter->format($tree);
        $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 30);
        $text = $formatter->format($tree);
    }
    return length($text)." bytes";
}

sub bench_css {
    my $iter = shift;
    my $file;
    my $html;
    for (1..$iter) {
        my $inliner = new CSS::Inliner();
        my $i = $_ % 2 + 1;
        $file = "data/wiki$i.html";
        $inliner->read_file({ filename => $file });
        $html = $inliner->inlinify();
    }
    return length($html)." bytes";
}

sub bench_datetime {
    my $iter = shift;
    my @tz   = ('UTC', 'Europe/London', 'America/New_York');
    my $str;
    for (1..$iter) {
        my $dt  = DateTime->now();
        my $dt1 = DateTime->from_epoch(
            epoch => 946684800 + rand(100000000),
        );
        my $dt2 = DateTime->from_epoch(
            epoch => 946684800 + rand(100000000),
        );
        $str = $dt2->strftime('%FT%T')."\n";
        eval {$dt2->set_time_zone($tz[int(rand(3))])};
        my $dur = $dt2->subtract_datetime($dt1);
        eval {$dt2->add_duration($dur)};
        $dt2->subtract(days => int(rand(1000)+1));
        $dt->week;
        $dt->epoch;
        $str = $dt2->strftime('%FT%T');
    }
    return $str;
}

sub bench_moose {
    my $iter = shift;
    my $cnt  = 0;
    require DKBench::MooseTree;
    for (1..$iter) {
        my $p    = rand(1000);
        my $root = DKBench::MooseTree->new(node => 'root');
        $root->price($p);
        $root->node;
        $root->cost;
        my $lchild = $root->left;
        $lchild->node('child');
        $lchild->price($p);
        $lchild->tax;
        my $child = $root->right;
        $child->cost;
        my $grandchild = $child->left;
        $grandchild->node('grandchild');
        $grandchild->has_parent;
        $grandchild->parent;
        $grandchild->price($p);
        $grandchild->cost;
        my $ggchild = $grandchild->right;
        $ggchild->cost;
        $cnt += 5;
    }
    return "$cnt objects";
}

sub bench_regex_repl {
    my $iter  = shift;
    my $enc   = shift || '';
    my $str   = read_wiki_files($enc);
    my $match = bench_regex($str, $iter);
    my $repl  = bench_replace($str, $iter);
    return "$match, $repl";
}

sub bench_regex {
    my $str  = shift;
    my $iter = shift;
    my $count;
    for (1..$iter) {
        $count = 0;
        $count += () = $str =~ /\b[A-Z][a-z]+/g;
        $count += () = $str =~ /[\w\.+-]+@[\w\.-]+\.[\w\.-]+/g;
        $count += () = $str =~ m![\w]+://[^/\s?#]+[^\s?#]+(?:\?[^\s#]*)?(?:#[^\s]*)?!g;
    }
    return "$count Matched";
}

sub bench_replace {
    my $str  = shift;
    my $iter = shift;
    my $count;
    for (1..$iter) {
        my $copy = $str;
        $count = 0;
        while (my $s = $copy =~ s#<([^>]+)>([^>]*?)</\1>#$2#g) {
            $count += $s;
        }
    }
    return "$count Replaced";
}

sub bench_moose_tests {
    my $iter = shift;
    my $result;
    $result = `prove -rQ data/t` for (1..$iter);
    if ($result =~ /(Result: \w*)/) {
        return $1;
    } else  {
        return 'Result: ?';
    }
}

sub pad_to {
    my $str = shift;
    my $len = shift || 24;
    return $str." "x($len-length($str));
}

sub read_wiki_files {
    my $enc = shift;
    my $str = "";
    for (0..2) {
        open my $fh, "<:$enc", "data/wiki$_.html" or die $!;
        $str .= do { local $/; <$fh> };
    }
    return $str;
}
