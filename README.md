# NAME

Benchmark::DKbench - Perl Benchmark

# SYNOPSIS

    # Run the suite single-threaded and then multi-threaded on multi-core systems
    # Will print scores for the two runs and multi/single thread scalability
    dkbench

    # A dual-thread run with times instead of scores
    dkbench -j 2 -t

    # If BioPerl is installed, enable the BioPerl benchmarks by downloading Genbank data
    dkbench --setup

    # Force install the reference versions of all CPAN modules
    setup_dkbench --force

# DESCRIPTION

A Perl benchmark suite for general compute, created to evaluate the comparative
performance of systems when running computationally intensive Perl (both pure Perl
and XS) workloads. Runs single and multi-threaded and can be fully customized to
the benchmarks that better suit your own scenario.

The only non-CPAN libraries required to install/run the suite are libdb, libjpeg
(with headers). There are a few prerequisite CPAN libraries, plus an optional one
([BioPerl](https://metacpan.org/pod/BioPerl), requires libxml on system) which enables extra benchmarks.

# SCRIPTS

You should only ever need the main script `dkbench` for the benchmark suite, and,
perhaps `setup_dkbench` can help with setup or standardizing/normalizing your
benchmarking environment.

## `dkbench`

The main script that runs the DKbench benchmark suite. If [BioPerl](https://metacpan.org/pod/BioPerl) is installed,
you may want to start your first run with `dkbench --setup`. Otherwise, there are
many options to control number of threads, iterations, which benchmarks to run etc:

    dkbench [options]

    Options:
    --threads <i>, -j <i> : Number of benchmark threads (default is 1).
    --multi,       -m     : Multi-threaded using all your CPU cores/threads.
    --iter <i>,    -i <i> : Number of suite iterations (with min/max/avg at the end).
    --include <regex>     : Run only benchmarks that match regex.
    --exclude <regex>     : Do not run benchmarks that match regex.
    --time,        -t     : Report time (sec) instead of score.
    --quick,       -q     : Quick benchmark run (implies -t).
    --no_mce              : Do not run under MCE::Loop (implies -j 1).
    --skip_bio            : Skip BioPerl benchmarks.
    --skip_timep          : Skip Time::Piece benchmark (see benchmark details on why).
    --skip_prove          : Skip Moose prove benchmark.
    --bio_codons          : Run optional BioPerl Codons benchmark (does not scale well).
    --sleep <i>           : Sleep for <i> secs after each benchmark.
    --setup               : Download the Genbank data to enable the BioPerl tests.
    --datapath <path>     : Override the path where the expected benchmark data is found.

The default run (no options) will run all the benchmarks both single-threaded and
multi-threaded (using all detected CPU cores/hyperthreads) and show you scores and
multi vs single threaded scalability.

The scores are such that a reference CPU (Intel Xeon Platinum 8481C - Sapphire Rapids)
would get 1000 on a single core benchmark run using the default software configuration
(Linux/Perl 5.36.0/ref CPAN modules).

The multi-thread scalability should approach 100% if each thread runs on a full core
(i.e. no SMT), and the core can maintain the clock speed it had on the single-thread
runs. Note that the overall scalability is an average of the benchmarks that drops
non-scaling outliers (over 2\*stdev less than the mean).

The suite will report a Pass/Fail per benchmark. A failure may be caused if you have
different CPAN module version installed - this is normal, and you will be warned.

The suite uses [MCE::Loop](https://metacpan.org/pod/MCE%3A%3ALoop) to run on the desired number of parallel threads, although
there is an option to disable it, which forces a single-thread run.

## `setup_dkbench`

Simple installer to check/get the reference versions of CPAN modules and download
the Genbank data file required for the BioPerl benchmarks of the DKbench suite.

It assumes that you have some software already installed (e.g. `cpanm`), try
`setup_dkbench --help` for more details on that.

    setup_dkbench [--force --sudo --test --data=s --help]

    Options:
    --sudo   : Will use sudo for cpanm calls.
    --force  : Will install reference CPAN module versions and re-download the genbank data.
    --test   : Will run the test suites for the CPAN module (default behaviour is to skip).
    --data=s : Data dir path to copy files from. Should not need if you installed DKbench.
    --help   : Print this help text and exit.

Running it without any options will fetch the data for the BioPerl tests (similar to
`dkbench --setup`) and use `cpanm` to install any missing libraries.

Using it with `--force` will install the reference CPAN module versions, including
BioPerl which is not a requirement for DKbench, but enables the BioPerl benchmarks.

The reference CPAN versions are suggested if you want a fair comparison between
systems and also for the benchmark Pass/Fail results to be reliable.

# BENCHMARKS

The suite consists of 19 benchmarks. With a successful installation of the DKbench
package, 18 will run by default, although the `BioPerl Monomers` requires BioPerl
to be installed and Genbank data to be downloaded (`dkbench --setup` can do the
latter).

On MacOS only, the `Time::Piece` benchmark will be skipped, unless you try a single
thread run without MCE (`--skip_mce`).

- `Astro` : Calculates precession between random epochs and finds the
constellation for random equatorial coordinates using [Astro::Coord::Precession](https://metacpan.org/pod/Astro%3A%3ACoord%3A%3APrecession)
and [Astro::Coord::Constellations](https://metacpan.org/pod/Astro%3A%3ACoord%3A%3AConstellations) respectively.
- `BioPerl Codons` : Counts codons on a sample bacterial sequence. Requires
[BioPerl](https://metacpan.org/pod/BioPerl) to be installed.
This test does not scale well on multiple threads, so is disabled by default (use
`--bio_codons`) option. Requires data fetched using the `--setup` option.
- `BioPerl Monomers` : Counts monomers on 500 sample bacterial sequences using
[BioPerl](https://metacpan.org/pod/BioPerl) (which needs to be installed). Requires data fetched using the `--setup`
option.
- `CSS::Inliner` : Inlines CSS on 2 sample wiki pages using [CSS::Inliner](https://metacpan.org/pod/CSS%3A%3AInliner).
- `Crypt::JWT` : Creates large JSON Web Tokens with RSA and EC crypto keys
using [Crypt::JWT](https://metacpan.org/pod/Crypt%3A%3AJWT).
- `DateTime` : Creates and manipulates [DateTime](https://metacpan.org/pod/DateTime) objects.
- `Digest` : Creates MD5, SH1 and SHA-512 digests of a large string.
- `Encode` : Encodes/decodes large strings from/to UTF-8/16, cp-1252.
- `HTML::FormatText` : Converts HTML to text for 2 sample wiki pages using
[HTML::FormatText](https://metacpan.org/pod/HTML%3A%3AFormatText).
- `Imager` : Loads a sample image and performs edits/manipulations with
[Imager](https://metacpan.org/pod/Imager), including filters like gaussian, unsharp mask, mandelbrot.
- `JSON::XS` : Encodes/decodes random data structures to/from JSON using
[JSON::XS](https://metacpan.org/pod/JSON%3A%3AXS).
- `Math::DCT` : Does 8x8, 18x18 and 32x32 DCT transforms with [Math::DCT](https://metacpan.org/pod/Math%3A%3ADCT).
- `Math::MatrixReal` : Performs various manipulations on [Math::MatrixReal](https://metacpan.org/pod/Math%3A%3AMatrixReal)
matrices.
- `Moose` : Creates [Moose](https://metacpan.org/pod/Moose) objects.
- `Moose prove` : Runs 110 tests from the Moose 2.2201 test suite. The least
CPU-intensive test, most of the time will be spent loading the interpreter and
the Moose module for each test, which is behaviour representative of how a Perl
test suite runs by default.
- `Primes` : Calculates all primes up to 7.5 million. Small number with
repeat was chosen to keep low memory (this is a pure Perl function no Math libraries).
- `Regex/Subst` : Concatenates 3 wiki pages into a byte string then matches
3 typical regexes (for names, emails, URIs), replaces html tags with their contents
(starting with the innermost) and does calls subst a few times.
- `Regex/Subst utf8` : Exactly the same as `Regex/Subst`, but reads into
a utf8 string. Perl version can make a big difference, as Unicode behaviour has
changed (old Perl versions are faster but less strict in general).
- `Time::Piece` : Creates and manipulates/converts Time::Piece objects. It
is disabled by default on MacOS (unless `--no_mce` is specified), as it runs
extremely slow when forked on this platform. In general you may want to skip this
benchmark (`--skip_timep`) if you are comparing different OS platforms.

# EXPORTED FUNCTIONS

You will normally not use the Benchmark::DKbench module itself, but here are the
exported functions that the `dkbench` script uses for reference:

## `system_identity`

    my $cores = system_identity();

Prints out software/hardware configuration and returns then number of cores detected.

## `suite_run`

    my %stats = suite_run(\%options);

Runs the benchmark suite given the `%options` and prints results. Returns a hash
with run stats.

## `calc_scalability`

    calc_scalability(\%options, \%stat_single, \%stat_multi);

Given the `%stat_single` results of a single-threaded `suite_run` and `%stat_multi`
results of a multi-threaded run, will calculate and print the multi-thread scalability.

# NOTES

The benchmark suite was created to compare the performance of various cloud offerings.
You can see the [original perl blog post](http://blogs.perl.org/users/dimitrios_kechagias/2022/03/cloud-provider-performance-comparison-gcp-aws-azure-perl.html)
as well as the [2023 follow-up](https://dev.to/dkechag/cloud-vm-performance-value-comparison-2023-perl-more-1kpp).

The benchmarks for the first version were more tuned to what I would expect to run
on the servers I was testing, to choose the optimal types for the company I was
working for. The second version has expanded a bit over that and is friendlier to
use.

# AUTHOR

Dimitrios Kechagias, `<dkechag at cpan.org>`

# BUGS

Please report any bugs or feature requests either on [GitHub](https://github.com/dkechag/Benchmark-DKbench) (preferred), or on RT (via the email
`bug-Benchmark-DKbench at rt.cpan.org` or [web interface](https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Benchmark-DKbench)).

I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

# GIT

[https://github.com/dkechag/Benchmark-DKbench](https://github.com/dkechag/Benchmark-DKbench)

# LICENSE AND COPYRIGHT

This software is copyright (c) 2021-2023 by Dimitrios Kechagias.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
