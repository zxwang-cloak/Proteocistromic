#!/usr/bin/perl 
use strict;
open IN, "$ARGV[0]" or die $!;
my%hash;

#my$t = <IN>;
#print "$t";

while (<IN>) {
	chomp;
	my@a = split /\t/;
	$hash{$a[0]} = $_;
}
close IN;

open IN2, "$ARGV[1]" or die $!;
while (<IN2>) {
	chomp;
	my@a = split /\t/;
	if (exists $hash{$a[0]}) {
		print "$_\n";
	}
}
close IN2;



