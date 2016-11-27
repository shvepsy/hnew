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

use constant CREATE	=> 0;
use constant DROP		=> 1;
use constant ADD		=> 2;
use constant DEL		=> 3;
use constant GRANT	=> 4;
use constant REVOKE	=> 5;
use constant PSWLEN	=> 14;
use constant LOGFILE	=> "./mgmt.log";

##open STDOUT, '>', LOGFILE or die "Can't redirect STDOUT: $!";
##open STDERR, ">&STDOUT" or die "Can't dup for STDERR: $!";
##STDOUT->autoflush(1);

open STDERR, '>>', LOGFILE or die "Can't dup for STDERR: $!";
STDERR->autoflush(1);

#my $pswlen = 12;

sub event {
	my $msg = shift;
	if (open (LOG, ">>",LOGFILE) ) {
	my $time = strftime "%H:%M:%S %d-%m-%Y", localtime;
		print LOG "$time: $msg\n";
		close LOG;
		exit 1 if ($msg =~ /ERR/ );
		return 0;
	}
	else {
		print "Can't open logfile";
		return 1;
	}
}

sub pwgen {
	my @sm = ("a".."z","A".."Z","0".."9");
	my $psw = join ("", @sm[map {rand @sm} (1..PSWLEN)]);
	return $psw;
}

sub dbctl {
	my $cmd = shift;
	my $cdb = shift;
	my $cdbuser = shift;
	my $dbh = DBI->connect("DBI:mysql:", "root", "rootpassword");
	#CREATE DROP ADD DEL GRANT REVOKE
	switch ($cmd) {
		case 0	{ $dbh->do("create database $cdb") or event("WNG: Can't create database $cdb") }
		case 1	{ $dbh->do("drop database $cdb") or event("WNG: Can't drop database $cdb") }
		case 2	{	my $tpw = pwgen; $dbh->do("create user \'$cdbuser\'\@\'localhost\' identified by \'$tpw\'") or event("WNG: Can't create user $cdbuser"); return $tpw }
		case 3	{ $dbh->do("drop user \'$cdbuser\'\@\'localhost\' ") or event("WNG: Can't drop user $cdbuser")}
		case 4	{	$dbh->do("grant all privileges on $cdb\.\* to \'$cdbuser\'\@\'localhost\'") or event("WNG: Can't grant on $cdb for $cdbuser")}
		case 5	{	$dbh->do("revoke all on $cdb\.\* from \'$cdbuser\'\@\'localhost\'") or event("WNG: Can't revoke on $cdb for $cdbuser")}
	}

	$dbh->disconnect(); #
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

dbctl(DEL,0,"tester");
dbctl(DROP,"test1","123");
dbctl(CREATE,"test1","123");
print dbctl(ADD, 0,"tester");
dbctl(GRANT,"test1","tester");
dbctl(REVOKE,"test1","tester");


#for (my $c = 0 ; $c < 10; $c++) {print pwgen()."\n"} ;
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
