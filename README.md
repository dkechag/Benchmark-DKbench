
## DKBench - Perl Benchmark

Perl benchmark that includes some workloads relevant to my real-world usage.

### Scripts

`setup.pl` - Setup script (downloads/unzips data files, installs 'recommended' module versions from cpan).
It Assumes you have at least tar/gunzip, File::Fetch and cpanm installed (e.g. `yum install perl-App-cpanminus` for CentOS 7, `apt install cpanminus` for Debian buster).
Any true argument uses `sudo` to `cpanm` commands.
In some systems you might need to install some modules (XML etc) with the package manager (e.g. `yum install perl-XML-LibXML perl-XML-Parser` for CentOS 7, `apt install libxml-simple-perl` for Debian buster).

`dkbench.pl` - Benchmark run. To try and compare objectively between systems, it checks for module and perl version and warns if the 'recommended' are not found. You can disable tests that either have too many dependencies or are of less interest with `--skip_bio`, `--skip_moose`, `--skip_dt`.

`prime_threads.pl` - Run the prime benchmark continuously over many threads and keep track of all runtimes to generate stats. Useful for systems that can reach throttling. Options: `--threads|t <n>`, `--iterations|i <n>`, `--max_prime|m <n>`.

### Benchmarks

 * **Astro:** Calculates precession between random epochs for 1 million random equatorial coordinates and finds the constellation for 100k random equatorial coordinates.
 * **BioPerl Codons:** Counts codons on a sample bacterial sequence.
 * **BioPerl Monomers:** Counts monomers on 500 sample bacterial sequences.
 * **CSS::Inliner:** Inlines CSS on 2 sample wiki pages 5 times each.
 * **DateTime:** Creates and manipulates 30k DateTime objects.
 * **Digest:** Creates MD5, SH1 and SHA-512 digests of a large string. 500x
 * **HTML::FormatText:** Converts HTML to text for 2 sample wiki pages 5 times x 2 layouts each.
 * **Math::DCT:** Does 1 million 8x8 DCT transforms and 50k 32x32 transforms. 
 * **Moose:** Creates 150k small Moose objects. Not the most useful benchmark, Moose is too slow (surely you are using Moo/Mouse etc instead?), but it is still quite commonly used.
 * **Primes:** Calculates all primes up to 10 million, x5 times. Small number with repeat was chosen to keep low memory (this is a pure Perl function).
 * **Regex/Replace:** Concatenates 3 wiki pages into a byte string then counts matches of 3 typical regexes (for names, emails, URIs) and replaces html tags with their contents (starting with the innermost). 25 repeats.
 * **Regex/Replace utf8:** Exactly the same as above, but reads into a utf8 string. Perl version can make a big difference, as unicode behaviour has changed (old Perl versions are faster but less strict in general).
 * **Test Moose:** Runs 110 tests from the Moose 2.2201 test suite. The least CPU-intensive test, most of the time will be spent loading the interpreter and the Moose module for each test, which is behaviour representative of how a perl test suite runs by default.

### Notes

The benchmark suite was created to compare the performance of various cloud offerings. See the [relevant perl blog post](http://blogs.perl.org/users/dimitrios_kechagias/2022/03/cloud-provider-performance-comparison-gcp-aws-azure-perl.html).

### License

 This software is copyright (c) 2021 by Dimitrios Kechagias.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
