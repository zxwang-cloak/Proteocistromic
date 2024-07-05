#!/usr/bin/perl -w
use strict;

my%hash;
open GROUP, "$ARGV[0]" or die $!;
while (<GROUP>) {
	chomp;
	my@a = split /\t/;
	$hash{$a[0]} = $a[1];
}
close GROUP;

open IN, "$ARGV[1]" or die $!;
print "ID\tDFS_MONTHS\tDFS_STATUS\t$ARGV[2]_$ARGV[3]_group\n";
while (<IN>) {
	chomp;
	my@a = split /\t/;
	my$ID = $a[1];
#	$a[1] =~ s/\./-/g;
	my$idA= "$a[1]-01";
	my$idB= "$a[1]-06";
	my$idC= "$a[1]-03";
	$a[2] =~ s/\:.*//g;
#	print "$idA\n";
	if (exists $hash{$idA})	{
		print "$idA\t$a[3]\t$a[2]\t$hash{$idA}\n";
	} elsif (exists $hash{$idB}) {
		print "$idB\t$a[3]\t$a[2]\t$hash{$idB}\n";
	} elsif (exists $hash{$idC}) {
		print "$idC\t$a[3]\t$a[2]\t$hash{$idC}\n";
	}
}
close IN;



