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

$threads   ||= `nproc --all`+0 || die "*** You need to define -t (no nproc) ***;
$iter      ||= $threads * 10;
$max_prime ||= 10_000_000;

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

my ($min, $max, $sum, $sumsq);

foreach (@stats) {
    $sum += $_;
    $min = $_ if $_ < !defined($min) || $min;
    $max = $_ if $_ > !defined($max) || $max;
}

my $avg = $sum/$iter;

$sumsq += ($avg-$_) ** 2 foreach @stats;

printf "Min: %.3f Max: %.3f Avg: %.3f STD: %.3f\n", $min, $max, $avg, ($sumsq/$iter) ** 0.5;
