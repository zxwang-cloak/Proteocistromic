#!/usr/bin/perl -w
use strict;

my@M;
my@N;

open IN, "$ARGV[0]" or die $!;
<IN>;
while (<IN>) {
	chomp;
	my@a = split /\t/;
	push @M, $a[1];
	push @N, $a[2];
}
close IN;

my$avg_M = average(@M);
my$avg_N = average(@N);

open IN2, "$ARGV[0]" or die $!;
my$t = <IN2>;
chomp($t);
my@T = split /\t/, $t;
print "sample\t$T[1]_$T[2]_group\n";
while (<IN2>) {
	chomp;
	my@a = split /\t/;
	if ($a[1] >= $avg_M && $a[2] >= $avg_N)	{
		print "$a[0]\t++\n";
	}elsif ($a[1] < $avg_M && $a[2] < $avg_N) {
		print "$a[0]\t--\n";
	}elsif ($a[1] >= $avg_M && $a[2] < $avg_N) {
		print "$a[0]\t+-\n";
	}elsif ($a[1] < $avg_M && $a[2] >= $avg_N) {
		print "$a[0]\t-+\n";
	}

}
close IN2;


sub average {
	my (@num) = @_;
	my $num = scalar @num;
	my $total;
	foreach (0..$#num) {
		$total += $num[$_];
	}
	return ($total/$num);
}

