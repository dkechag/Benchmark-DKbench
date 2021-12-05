package DKBench::Prime;

use strict;
use warnings;


# modified from https://github.com/famzah/langs-performance/blob/master/primes.pl

sub get_primes {
    my $n = shift || 100_000_000;
    my @s = ();
    for (my $i = 3; $i < $n + 1; $i += 2) {
        push(@s, $i);
    }
    my $mroot = $n**0.5;
    my $half  = scalar @s;
    my $i     = 0;
    my $m     = 3;
    while ($m <= $mroot) {
        if ($s[$i]) {
            for (my $j = int(($m * $m - 3) / 2); $j < $half; $j += $m) {
                $s[$j] = 0;
            }
        }
        $i++;
        $m = 2 * $i + 3;
    }

    return 2, grep($_, @s);
}


return 1;