#!/usr/bin/perl -w
use strict;
open IN, "$ARGV[0]" or die $!;

my$com = 1;
while (<IN>) {
	chomp;
	my@a = split /\t/;
	foreach my$i(@a) {
		print "$com\t$i\n";
	}
	$com = $com + 1;
}
close IN;



