# NAME

Benchmark::DKbench - Perl CPU Benchmark Suite

# SYNOPSIS

    # Run the suite single-threaded and then multi-threaded on multi-core systems
    # Will print scores for the two runs and multi/single thread scalability
    dkbench

    # A dual-thread "quick" run (with times instead of scores)
    dkbench -j 2 -q

    # If BioPerl is installed, enable the BioPerl benchmarks by downloading Genbank data
    dkbench --setup

    # Force install the reference versions of all CPAN modules
    setup_dkbench --force

# DESCRIPTION

A Perl benchmark suite for general compute, created to evaluate the comparative
performance of systems when running computationally intensive Perl (both pure Perl
and C/XS) workloads. It is a good overall indicator for generic CPU performance in
real-world scenarios. It runs single and multi-threaded (able to scale to hundreds
of CPUs) and can be fully customized to run the benchmarks that better suit your own
scenario - even allowing you to add your own custom benchmarks.

# INSTALLATION

See the ["setup\_dkbench"](#setup_dkbench) script below for more on the installation of a couple
of optional benchmarks and standardizing your benchmarking environment, otherwise
here are some general guidelines for various systems.

## Linux / WSL etc

The only non-CPAN software required to install/run the suite is a build environment
for the C/XS modules (C compiler, make etc.) and Perl. On the most popular Linux
package managers you can easily set up such an environment (as root or with sudo):

    # Debian/Ubuntu etc
    apt-get update
    apt-get install build-essential perl cpanminus

    # CentOS/Red Hat
    yum update
    yum install gcc make patch perl perl-App-cpanminus

After that, you can use [App::cpanminus](https://metacpan.org/pod/App%3A%3Acpanminus) to install the benchmark suite (as
root/sudo is the easiest, will install for all users):

    cpanm -n Benchmark::DKbench

## Solaris

You will need to install the Oracle Solaris Studio development package to have a
compiler environment, and to add its `bin` directory to your PATH, before installing
the benchmark suite.

## Strawberry Perl

If you are on Windows, you should be using the Windows Subsystem for Linux (WSL)
for running Perl or, if you can't (e.g. old Windows versions), cygwin instead.
The suite should still work on Strawberry Perl, as long as you don't try to run
tests when installing (some dependencies will not pass them). The simplest way is
with [App::cpanminus](https://metacpan.org/pod/App%3A%3Acpanminus) (most Strawberry Perl verions have it installed):

    cpanm -n Benchmark::DKbench

otherwise with the base CPAN shell:

    perl -MCPAN -e shell

    > notest install Benchmark::DKbench

and then note that the scripts get the batch extension appended, so `dkbench.bat`
runs the suite (and `setup_dkbench.bat` can assist with module versions, optional
benchmarks etc.).

Be aware that Strawberry Perl is slower, on my test system I get almost 50% slower
performance than WSL and 30% slower than cygwin.

# SCRIPTS

You will most likely only ever need the main script `dkbench` which launches the
suite, although `setup_dkbench` can help with setup or standardizing/normalizing your
benchmarking environment.

## `dkbench`

The main script that runs the DKbench benchmark suite. If [BioPerl](https://metacpan.org/pod/BioPerl) is installed,
you may want to start with `dkbench --setup`. But beyond that, there are many
options to control number of threads, iterations, which benchmarks to run etc:

    dkbench [options]

    Options:
    --threads <i>, -j <i> : Number of benchmark threads (default is 1).
    --multi,       -m     : Multi-threaded using all your CPU cores/threads.
    --max_threads <i>     : Override the cpu detection to specify max cpu threads.
    --iter <i>,    -i <i> : Number of suite iterations (with min/max/avg at the end).
    --stdev               : Show relative standard deviation (for iter > 1).
    --include <regex>     : Run only benchmarks that match regex.
    --exclude <regex>     : Do not run benchmarks that match regex.
    --time,        -t     : Report time (sec) instead of score.
    --quick,       -q     : Quick benchmark run (implies -t).
    --no_mce              : Do not run under MCE::Loop (implies -j 1).
    --scale <i>,   -s <i> : Scale the bench workload by x times (incompatible with -q).
    --skip_bio            : Skip BioPerl benchmarks.
    --skip_prove          : Skip Moose prove benchmark.
    --time_piece          : Run optional Time::Piece benchmark (see benchmark details).
    --bio_codons          : Run optional BioPerl Codons benchmark (does not scale well).
    --sleep <i>           : Sleep for <i> secs after each benchmark.
    --setup               : Download the Genbank data to enable the BioPerl tests.
    --datapath <path>     : Override the path where the expected benchmark data is found.
    --ver <num>           : Skip benchmarks added after the specified version.
    --help         -h     : Show basic help and exit.

The default run (no options) will run all the benchmarks both single-threaded and
multi-threaded (using all detected CPU cores/hyperthreads) and show you scores and
multi vs single threaded scalability.

The scores are calibrated such that a reference CPU (Intel Xeon Platinum 8481C -
Sapphire Rapids) would achieve a score of 1000 in a single-core benchmark run using
the default software configuration (Linux/Perl 5.36.0 built with multiplicity and
threads, with reference CPAN module versions). Perl built without thread support and
multi(plicity) will be a bit faster (usually in the order of ~3-4%), while older Perl
versions will most likely be slower. Different CPAN module versions will also impact
scores, using `setup_dkbench` is a way to ensure a reference environment for more
meaningful hardware comparisons.

The multi-thread scalability calculated by the suite should approach 100% if each
thread runs on a full core (i.e. no SMT), and the core can maintain the clock speed
it had on the single-thread runs. Note that the overall scalability is an average
of the benchmarks that drops non-scaling outliers (over 2\*stdev less than the mean).

If you want to reduce the effects of thermal throttling, which will lower the speed
of (mainly multi-threaded) benchmarks as the CPU temperature increases, the `sleep`
option can help by adding cooldown time between each benchmark.

The suite will report a Pass/Fail per benchmark. A failure may be caused if you have
different CPAN module version installed - this is normal, and you will be warned.

[MCE::Loop](https://metacpan.org/pod/MCE%3A%3ALoop) is used to run on the desired number of parallel threads, with minimal
overhead., There is an option to disable it, which forces a single-thread run.

## `setup_dkbench`

Simple installer to check/get the reference versions of CPAN modules and download
the Genbank data file required for the BioPerl benchmarks of the DKbench suite.

It assumes that you have some software already installed (see ["INSTALLATION"](#installation) above),
try `setup_dkbench --help` will give you more details.

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

The reference Perl and CPAN versions are suggested if you want a fair comparison
between systems and also for the benchmark Pass/Fail results to be reliable.

# BENCHMARKS

The suite consists of 21 benchmarks, 19 will run by default. However, the
`BioPerl Monomers` requires the optional [BioPerl](https://metacpan.org/pod/BioPerl) to be installed and Genbank
data to be downloaded (`dkbench --setup` can do the latter), so you will only
see 18 benchmarks running just after a standard install. Because the overall score
is an average, it is generally unaffected by adding or skipping a benchmark or two.

The optional benchmarks are enabled with the `--time_piece` and `--bio_codons`
options.

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
- `DBI/SQL` : Creates a mock [DBI](https://metacpan.org/pod/DBI) connection (using [DBD::Mock](https://metacpan.org/pod/DBD%3A%3AMock)) and passes
it insert/select statements using [SQL::Inserter](https://metacpan.org/pod/SQL%3A%3AInserter) and [SQL::Abstract::Classic](https://metacpan.org/pod/SQL%3A%3AAbstract%3A%3AClassic).
The latter is quite slow at creating the statements, but it is widely used.
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
CPU-intensive test (which is why there is the option `--no_prove` to disable it),
most of the time will be spent loading the interpreter and the Moose module for each
test, which is behaviour representative of how a Perl test suite runs by default.
- `Primes` : Calculates all primes up to 7.5 million. Small number with
repeat was chosen to keep low memory (this is a pure Perl function no Math libraries).
- `Regex/Subst` : Concatenates 3 wiki pages into a byte string then matches
3 typical regexes (for names, emails, URIs), replaces html tags with their contents
(starting with the innermost) and does calls subst a few times.
- `Regex/Subst utf8` : Exactly the same as `Regex/Subst`, but reads into
a utf8 string. Perl version can make a big difference, as Unicode behaviour has
changed (old Perl versions are faster but less strict in general).
- `Text::Levenshtein` : The edit distance for strings of various lengths (up
to 2500) are calculated using [Text::Levenshtein::XS](https://metacpan.org/pod/Text%3A%3ALevenshtein%3A%3AXS) and [Text::Levenshtein::Damerau::XS](https://metacpan.org/pod/Text%3A%3ALevenshtein%3A%3ADamerau%3A%3AXS).
- `Time::Piece` : Creates and manipulates/converts Time::Piece objects. It
is disabled by default because it uses the OS time libraries, so it might skew results
if you are trying to compare CPUs on different OS platforms. It can be enabled with
the `--time_piece` option. For MacOS specifically, it can only be enabled if `--no_mce`
is specified, as it runs extremely slow when forked.

# EXPORTED FUNCTIONS

You will normally not use the Benchmark::DKbench module itself, but here are the
exported functions that the `dkbench` script uses for reference:

## `system_identity`

    my $cores = system_identity($quiet?);

Prints out software/hardware configuration and returns the number of logical cores
detected using [System::CPU](https://metacpan.org/pod/System%3A%3ACPU).

Any argument will suppress printout and will only return the number of cores.

## `suite_run`

    my %stats = suite_run(\%options);

Runs the benchmark suite given the `%options` and prints results. Returns a hash
with run stats that looks like this:

    %stats = (
      bench_name => {times => [ ... ], scores => [ ... ]},
       ...
      _total => {times => [ ... ], scores => [ ... ]},
      _opt   => {iter => $iterations, threads => $no_threads, ...}
    );

The options of the `dkbench` script (in their long form) are accepted, except
`help`, `setup` and `max_threads` which are exclusive to the command-line script.

In addition, `%options` may contain the key `extra_bench`, with a hashref value
containing custom benchmarks in the following format:

    extra_bench => { bench_name => [$coderef, $exp_output, $ref_time, $quick_arg, $normal_arg], ... }

Where `bench_name` is a unique name for each benchmark and the arrayref assigned
to it contains: A reference to the benchmarking code, the expected output (string)
for the test to be considered a pass, the reference time in seconds for a score of
1000, an argument (workload scaling) to pass to the function for the `quick` bench
run and an argument to pass for the normal run. If the second argument is undef,
a "Pass" is always recorded, if the third argument is not defined and non-zero,
`time` will be implied.

For more info with an example see the ["CUSTOM BENCHMARKS"](#custom-benchmarks) section.

## `calc_scalability`

    my %scal = calc_scalability(\%stat_single, \%stat_multi);

Given the `%stat_single` results of a single-threaded `suite_run` and `%stat_multi`
results of a multi-threaded run, will calculate, print and return the multi-thread
scalability (including averages, ranges etc for multiple iterations.

The result hash return looks like this:

    %scal = (
      bench_name => $bench_avg_scalability,
       ...
      _total => $total_avg_scalability
    );

# CUSTOM BENCHMARKS

Version 2.5 introduced the ability to add custom benchmarks to be run along any
of the included ones of the suite. This allows you to create a suite that is more
relevant to you, by including the actual code you will be running on the systems
you are benchmarking.

Here is an example of adding a benchmark to the test suite and running it together
with the default benchmarks:

    use Benchmark::DKbench;
    use Math::Trig qw/:great_circle :pi/;

    sub great_circle {
      my $iter = shift || 1;  # Optionally have an argument that scales the workload
      my $dist = 0;
      $dist +=
        great_circle_distance(rand(pi), rand(2 * pi), rand(pi), rand(2 * pi))
          for 1 .. $iter;
      return $dist; # Returning something is optional, but is used to Fail bench on no match
    }

    my %stats = suite_run({
        extra_bench => { 'Math::Trig' =>  # A unique name for the benchmark
          [
          \&great_circle,      # Reference to bench function
          '3144042.81433949',  # Output for your reference Perl - determines Pass/Fail (optional)
          5.5,                 # Seconds to complete in normal mode for score = 1000 (optional)
          1000000,             # Argument to pass for --quick mode (optional)
          5000000              # Argument to pass for normal mode (optional)
          ]},
      }
    );

You can use a prefix for the naming of your custom benchmarks and make use of the
`include` argument to run only the custom benchmarks. Here is an example, where
a custom test is defined inline, without any of the optional arguments and specified
to run by itself:

    my %stats = suite_run({
        include     => 'custom',
        extra_bench => { custom1 => [sub {my @a=split(//, 'x'x$_) for 1..10000}] }
      }
    );

If you want to do a multi-threaded run as well and then calculate scalability:

    my %stats_multi = suite_run({
        threads     => system_identity(1);
        include     => 'custom',
        extra_bench => { custom1 => [sub {my @a=split(//, 'x'x$_) for 1..10000}] }
      }
    );

    my %scal = calc_scalability(\%stats, \%stats_multi);

# NOTES

The benchmark suite was created to compare the performance of various cloud offerings.
You can see the [original perl blog post](http://blogs.perl.org/users/dimitrios_kechagias/2022/03/cloud-provider-performance-comparison-gcp-aws-azure-perl.html)
as well as the [2023 follow-up](https://dev.to/dkechag/cloud-vm-performance-value-comparison-2023-perl-more-1kpp).

The benchmarks for the first version were more tuned to what I would expect to run
on the servers I was testing, in order to choose the optimal types for the company
I was working for. The second version has expanded a bit over that, and is friendlier
to use.

Although this benchmark is in general a good indicator of general CPU performance
and can be customized to your needs, no benchmark is as good as running your own
actual workload (which can be done via the ["CUSTOM BENCHMARKS"](#custom-benchmarks) functionality).

## SCORES

Some sample DKbench score results from various systems for comparison (all on
reference setup with Perl 5.36.0 thread-multi):

    CPU                                     Cores/HT   Single   Multi   Scalability
    Intel i7-4750HQ @ 2.0 (MacOS)                4/8     612     2332      46.9%
    AMD Ryzen 5 PRO 4650U @ 2.1 (WSL)           6/12     905     4444      40.6%
    Apple M1 Pro @ 3.2 (MacOS)                 10/10    1283    10026      78.8%
    Apple M2 Pro @ 3.5 (MacOS)                 12/12    1415    12394      73.1%
    Ampere Altra @ 3.0 (Linux)                 48/48     708    32718      97.7%
    Intel Xeon Platinum 8481C @ 2.7 (Linux)   88/176    1000    86055      48.9%
    AMD EPYC Milan 7B13 @ 2.45 (Linux)       112/224     956   104536      49.3%
    AMD EPYC Genoa 9B14 @ 2.7 (Linux)        180/360    1197   221622      51.4%

# AUTHOR

Dimitrios Kechagias, `<dkechag at cpan.org>`

# BUGS

Please report any bugs or feature requests either on [GitHub](https://github.com/dkechag/Benchmark-DKbench) (preferred), or on RT (via the email
`bug-Benchmark-DKbench at rt.cpan.org` or [web interface](https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Benchmark-DKbench)).

I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

# GIT

[https://github.com/dkechag/Benchmark-DKbench](https://github.com/dkechag/Benchmark-DKbench)

# LICENSE AND COPYRIGHT

This software is copyright (c) 2021-2024 by Dimitrios Kechagias.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
