#!/usr/bin/env perl

use strict;
use warnings;

#use JSON;
use POSIX qw(strftime);
#use JSON::Parse 'valid_json';
use JSON::Parse ':all';
use JSON qw( decode_json );
use Data::Dumper;

sub event {
	my $msg = shift;
	if (open (LOG, ">>./mgmt.log") ) {
	my $time = strftime "%H:%M:%S %d-%m-%Y", localtime;
		print LOG "$time: $msg\n";
		close LOG;
		#print "$msg\n"; #
		exit 1 if ($msg =~ /ERR/ );
		return 0;
	}
	else {
		print "Can't open logfile";
		return 1;
	}
}

# Read JOSN conf
event("Start");
my $jsonr;
open (FH, "<./test.json") or event("ERR:Can't open json\n");
while (<FH>) { $jsonr .= $_ } ;
close FH;
event("ERR:Invalid JSON") unless (valid_json ($jsonr));

my $jsonp =  parse_json ( $jsonr );

#my $f = 1;
my $i = 0;
my @uids;


while ($jsonp->[$i]->{userid}) {
#	print $jsonp->[$i]->{userid},"\n" ;
	$uids[$i] = $jsonp->[$i]->{userid};
	$i++;
}
foreach my $t (@uids) { print $t,"\n" }

#foreach my $t (0 .. $#uids) { print "$t $jsonp->[$t]->{userid}  $jsonp->[$t]->{sitename} $jsonp->[$t]->{phpver}\n" };

foreach my $t (0 .. $#uids) {
	print "$t $jsonp->[$t]->{userid}  $jsonp->[$t]->{sitename} $jsonp->[$t]->{phpver}\n";
#}
	for (my $c = 0; $jsonp->[$t]->{db}->[$c]->{dbname}; $c++) {
			for (my $z = 0; $jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]; $z++) {
				print " $jsonp->[$t]->{db}->[$c]->{dbname} $jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]\n" ;

#				for (my $c = 0; $jsonp->[$t]->{db}->[$c]->{dbname}; $c++) {
#						for (my $z = 0; $jsonp->[$t]->{db}->[$c]->{dbname}; $z++) {
#							print " $jsonp->[$t]->{db}->[$c]->{dbname} $jsonp->[$t]->{db}->[$c]->{dbname} "

		}
	}
}
#print join(", ", @array); #
#for (my $i = 0; $i < 10; $i++ ) {
#	print %jsonp;
#	print $jsonp->[$i]->{userid},"\n" ;
#}

#while (for ) {
#	print
#}

#print Dumper($jsonp);
#print $jsonr;
#print $jsonp;
event("End");
exit 0;
