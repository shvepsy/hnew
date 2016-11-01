#!/usr/bin/env perl

use strict;
use warnings;
use Switch;
#use JSON;
use DBI;
use POSIX qw(strftime);
use JSON::Parse ':all';
#use JSON qw( decode_json );
#use JSON::Parse 'valid_json';

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

sub dbctl {
	my $cmd = shift;
	my $cdb = shift;
	my @cdbusers = shift;
	my $dbh = DBI->connect("DBI:mysql:", "root", "rootpassword");
	switch ($cmd) {
		case "create"	{ $dbh->do("create database $cdb"); }
		case "drop"		{}
		case "add"		{}
		case "del"		{}
		case "grant"	{}
		case "forbid"	{}
	}
	case

	$dbh->disconnect(); #
}

sub pwgen { ####
	my $len = shift;

	for ($i = 1;$i<=$use{many};$i++)
	{
		$use{psw} = join ("", @sm[map {rand @sm} (1..$use{count})]);
	}
}

event("Start");
#my $dbh = DBI->connect("DBI:mysql:", "root", "rootpassword");
#$dbh->disconnect(); #

# Read JOSN conf
my $jsonr;
open (FH, "<./test.json") or event("ERR:Can't open json\n");
while (<FH>) { $jsonr .= $_ } ;
close FH;
event("ERR:Invalid JSON") unless (valid_json ($jsonr));

# Зarse in hash
my $jsonp =  parse_json ( $jsonr );


my @uids;
for ( my $t = 0; $jsonp->[$t]->{userid}; $t++) {
	print "num:$t\tid:$jsonp->[$t]->{userid}\tsitename: $jsonp->[$t]->{sitename}\tphpver: $jsonp->[$t]->{phpver}\tactive: $jsonp->[$t]->{active}\t";
	print "mirrors: " . join(", ", @{$jsonp->[$t]->{mirrors}}) . "\n"; #
	for (my $c = 0; $jsonp->[$t]->{db}->[$c]->{dbname}; $c++) {
			for (my $z = 0; $jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]; $z++) {
				print "db $jsonp->[$t]->{db}->[$c]->{dbname}\tdbuser $jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]\n" ;
				#print " $jsonp->[$t]->{db}->[$c]->{dbname} $jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]\n" ;
				#print join(", ", @{$jsonp->[$t]->{db}->[$c]->{dbuser}}) . "\n"; #
				print "dbusers: " . join(", ", @{$jsonp->[$t]->{db}->[$c]->{dbuser}}) . "\n"; #
		}
	}
	print "\n";
}

#print join(", ", @array); #



#print Dumper($jsonp);
#print $jsonr;
#print $jsonp;
event("End");
exit 0;
