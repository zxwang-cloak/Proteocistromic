#!/usr/bin/perl -w
use strict;
my%hash;

open INDEX, "$ARGV[0]" or die $!;
while (<INDEX>) {
	chomp;
	my@a = split /\t/;
	$hash{$a[1]} = $a[0];
}
close INDEX;

open FILE, "$ARGV[1]" or die $!;
while (<FILE>) {
	chomp;
	my@a = split /\t/;
	if (exists $hash{$a[0]} && exists $hash{$a[1]}) {
		if ($hash{$a[0]} ne $hash{$a[1]}) {
			print "$hash{$a[0]}\t$hash{$a[1]}\n";
		}
	}
}
close FILE;


