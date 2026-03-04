#!/usr/bin/perl 
use strict;
open IN, "$ARGV[0]" or die $!;
my%hash;

#my$t = <IN>;
#print "$t";

while (<IN>) {
	chomp;
	my@a = split /\t/;
	$hash{$a[0]} = $a[1];
}
close IN;

open IN2, "$ARGV[1]" or die $!;
while (<IN2>) {
	chomp;
	my@a = split /\t/;
	if (exists $hash{$a[0]} && $hash{$a[2]}) {
		print "$a[0]\t$hash{$a[0]}\t$a[1]\t$a[2]\t$hash{$a[2]}\t$a[3]\n";
	} else {
		if (exists $hash{$a[0]}) {
			print "$a[0]\t$hash{$a[0]}\t$a[1]\t$a[2]\tnone\t$a[3]\n";
		} elsif (exists $hash{$a[2]}) {
			print "$a[0]\tnone\t$a[1]\t$a[2]\t$hash{$a[2]}\t$a[3]\n";
		} else {
			print "$a[0]\tnone\t$a[1]\t$a[2]\tnone\t$a[3]\n";
		}
	}
}
close IN2;



