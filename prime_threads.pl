#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use DKBench::Prime;
use Getopt::Long;
use MCE::Loop;
use Time::HiRes;

GetOptions (
    't|threads=i'    => \my $threads,
    'i|iterations=i' => \my $iter,
    'm|max_prime=i'  => \my $max_prime,
);

$threads   ||= `nproc --all`+0 || die "*** You need to define -t (no nproc) ***";
$iter      ||= $threads * ($threads > 1 ? 10 : 20);
$max_prime ||= 10_000_000;

print "Perl version $^V\n";
print "Finding primes to $max_prime on $threads threads, $iter iterations:\n";

MCE::Loop::init {
    max_workers => $threads,
    chunk_size  => 1
};

my @stats = mce_loop {
    my ($mce, $chunk_ref, $chunk_id) = @_;

    for (@{$chunk_ref}) {
        my $i      = $_;
        my $start  = Time::HiRes::time();
        my @primes = DKBench::Prime::get_primes($max_prime);
        my $time   = sprintf("%.3f", Time::HiRes::time()-$start);
        MCE->gather($time);
        MCE->say("$i:\t$time");
    }
} (1..$iter);

my ($sum, $sumsq, $five, $nfive) = (0, 0, ($iter-1)*0.05, ($iter-1)*0.95);

@stats = sort @stats;
$sum += $_ foreach @stats;

my $avg = $sum/$iter;

$sumsq += ($avg-$_) ** 2 foreach @stats;

printf "Min: %.3f Max: %.3f 5%%: %.3f 95%%: %.3f Avg: %.3f STD: %.3f\n",
    $stats[0], $stats[-1], $stats[int($five+0.5)], $stats[int($nfive+0.5)], $avg, ($sumsq / $iter)**0.5;
