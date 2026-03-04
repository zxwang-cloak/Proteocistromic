#!/usr/bin/perl -w
use strict;

my%hash;
open DC, "$ARGV[0]" or die $!;
while (<DC>) {
	chomp;
	my@a = split /\t/;
	$hash{$a[0]} = $a[1];
}
close DC;

my$all = `wc -l noself-community-info.txt`;
my@all_arry = split /\s+/, $all;
my$all_link = $all_arry[0];

print "C1\tC2\tBoth\tJust_community_1\tJust_community_2\tNeither\n";

open DPC, "$ARGV[1]" or die $!;
while (<DPC>) {
	chomp;
	my@b = split /\t/;
	my$both = $b[2];
	my$just_domain_1 = $hash{$b[0]}	- $both;
	my$just_domain_2 = $hash{$b[1]} - $both;
	my$Neither = $all_link - $both - $just_domain_1 - $just_domain_2;
	
	print "$_\t$just_domain_1\t$just_domain_2\t$Neither\n";
}
close DPC;



