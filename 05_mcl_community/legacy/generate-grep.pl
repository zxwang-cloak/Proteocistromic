#!/usr/bin/perl -w
use strict;
open IN, "$ARGV[0]" or die $!;
while (<IN>) {
	chomp;
	print "grep -w \"$_\" noself-community-info.txt | wc -l >> Community-count.txt\n";
}
close IN;


