#!/usr/bin/env perl

use strict; 
use warnings;

#use JSON;
use POSIX qw(strftime);
#use JSON::Parse 'valid_json';
use JSON::Parse ':all';
use Data::Dumper;

sub event {
	my $msg = shift;
	if (open (LOG, ">>./mgmt.log") ) { 
	my $time = strftime "%e %b %H:%M:%S %Y", localtime;
		print LOG "$time: $msg\n";
		close LOG; 
		print "$msg\n"; #
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

my $f = 1;
my $i = 0;
while (for ) { 
	print  
}

#print Dumper($jsonp);
#print $jsonr; 
#print $jsonp; 
event("End");
exit 0;


