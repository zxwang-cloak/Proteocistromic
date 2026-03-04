#!/usr/bin/perl -w
use strict;
my%hash;
open IN, "$ARGV[0]" or die $!;
while (<IN>) {
	chomp;
	my@a = split /\t/;
	$hash{$a[1]} = $a[0];
}
close IN;

foreach my$k (keys %hash) {
	print "$k\t$hash{$k}\n";
}


