#!/usr/bin/env perl

BEGIN {
    use Time::HiRes;
    my $start = Time::HiRes::time();
}

use strict;
use warnings;

use lib 'lib';

use Astro::Coord::Constellations 'constellation_for_eq';
use Astro::Coord::Precession 'precess';
use Bio::SeqIO; 
use Bio::Tools::SeqStats; 
use CSS::Inliner;
use DKBench::MooseTree;
use DKBench::Prime;
use HTML::FormatText;
use HTML::TreeBuilder;

print "Perl version $^V\n";
version_warnings();
srand(1); # For repeatability

my $start = time();

my %benchmarks = (
    'Astro'  => sub { bench_astro(100_000) },
    'BioPerl Codons' => sub { bench_bioperl_codons(1,5) },
    'BioPerl Monomers' => sub { bench_bioperl_mono(500) },
    'CSS::Inliner' => sub { bench_css(10) },
    'HTML::FormatText' => sub { bench_formattext(10) },
    'Moose' => sub { bench_moose(50_000) },
    'Moose Tests' => sub { bench_moose_tests(1) },
    'Primes' => sub { bench_primes(5, 20_000_000) },
    'Regex' => sub { bench_regex(100) },
    'Replace' => sub { bench_replace(100) },
);

print pad_to("Test").pad_to("Time (sec)")."Last run result\n";

foreach my $bench (sort keys %benchmarks) {
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
        'Bio::SeqIO'               => '1.7.8',
        'HTML::Parser'             => 3.76,
        'HTML::FormatText'         => 2.16,
        'HTML::TreeBuilder'        => 5.07,
        'CSS::Inliner'             => 4014
    );

    foreach my $module (keys %mod_ver) {
        warn "! $module $mod_ver{$module} recommended as a comparison base\n"
        unless eval "\$${module}::VERSION" eq $mod_ver{$module};

    }
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
    for (0..$iter-1) {
        my $i = $_ % 2;
        $file = "data/wiki$i.html";
        my $tree = HTML::TreeBuilder->new->parse_file($file);
        my $formatter = HTML::FormatText->new();
        my $text = $formatter->format($tree);
        $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 30);
        $text = $formatter->format($tree);
    }
    return "Processed $file";
}

sub bench_css {
    my $iter = shift;
    my $file;
    for (1..$iter) {
        my $inliner = new CSS::Inliner();
        my $i = $_ % 2 + 1;
        $file = "data/wiki$i.html";
        $inliner->read_file({ filename => $file });
        my $html = $inliner->inlinify();
    }
    return "Processed $file";
}

sub bench_moose {
    my $iter = shift;
    my $cnt  = 0;
    for (1..$iter) {
        my $root = DKBench::MooseTree->new(node => 'root');
        my $lchild = $root->left;
        $root->node;
        $root->cost;
        $lchild->node('child');
        my $child = $root->right;
        my $grandchild = $child->left;
        $grandchild->node('grandchild');
        $grandchild->has_parent;
        $grandchild->parent;
        $grandchild->cost;
        my $ggchild = $grandchild->right;
        $cnt += 4;
    }
    return "$cnt objects";
}

sub bench_regex {
    my $iter = shift;
    my $str = "DKBench  "x1000;
    for (0..2) {
        open my $fh, '<', "data/wiki$_.html" or die $!;
        $str .= do { local $/; <$fh> };
    }
    my $count;
    for (1..$iter) {
        $count = 0;
        $count += () = $str =~ /\b[A-Z][a-z]+/g;
        $count += () = $str =~ /[\w\.+-]+@[\w\.-]+\.[\w\.-]+/g;
        $count += () = $str =~ m![\w]+://[^/\s?#]+[^\s?#]+(?:\?[^\s#]*)?(?:#[^\s]*)?!g;
    }
    return "$count Matches";
}

sub bench_replace {
    my $iter = shift;
    my $str = "";
    for (0..2) {
        open my $fh, '<', "data/wiki$_.html" or die $!;
        $str .= do { local $/; <$fh> };
    }
    my $count;
    for (1..$iter) {
        my $copy = $str;
        $count = 0;
        while (my $s = $copy =~ s#<([^>]+)>([^>]*?)</\1>#$2#g) {
            $count += $s;
        }
    }
    return "$count Replacements";
}

sub bench_moose_tests {
    my $iter = shift;
    my $result;
    $result = `prove -rQ t` for (1..$iter);
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
