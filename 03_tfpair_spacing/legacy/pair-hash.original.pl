#!/usr/bin/perl -w
use strict;

my %hash;

open IN, "$ARGV[0]" or die $!;
while (<IN>) {
	chomp;
	my@a = split /\t/;
	$hash{$a[0]}{$a[1]} = $_;
}
close IN;

open IN2, "$ARGV[1]" or die $!;
while (<IN2>) {
	chomp;
	my@a = split /\t/;
	if (exists $hash{$a[0]}{$a[1]}) {
		next;
	} else {
		print "$_\n";
	}

}
close IN2;



