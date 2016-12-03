#!/usr/bin/env perl

use strict;
use warnings;
use Switch;
#use JSON;
use Fcntl;
use DBI;
use POSIX qw(strftime);
use JSON::Parse ':all';
use Digest::MD5 'md5_base64';
#use JSON qw( decode_json );
#use JSON::Parse 'valid_json';
use Data::Dumper;

use constant {
	CREATE	=>	0,
	DROP		=>	1,
	ADD			=>	2,
	DEL			=>	3,
	GRANT		=>	4,
	REVOKE	=>	5,
	PSWLEN	=>	14,
	LOGFILE	=>	"./mgmt.log",
	USRPATH	=>	"./users/",
	DBROOT	=>	"root",
	DBRPSW	=>	"rootpassword",
	MGMTDB	=>	"hosting",
};

# log/events requirement
open LOG, '>>', LOGFILE or die "Can't open logfile: $!";
LOG->autoflush(1);
open STDERR, '>>', LOGFILE or die "Can't dup for STDERR: $!";
STDERR->autoflush(1);

sub event {
	my $msg = shift;
	my $time = strftime("%H:%M:%S %d-%m-%Y", localtime);
	if (print LOG "$time: $msg\n" ) {
		if ($msg =~ /ERR/ ) {
			close LOG; exit 1;
		}; 											# Rewrite to event(1,"message")
		return 0;
	}
	else {
		print "Can't write to logfile: $!";
		return 1;
	}
}

# Simple pass generator
sub pwgen {
	my @sm = ("a".."z","A".."Z","0".."9");
	my $psw = join ("", @sm[map {rand @sm} (1..PSWLEN)]);
	return $psw;
}

# DB connect and sub definition
our $dbh = DBI->connect("DBI:mysql:" . MGMTDB , DBROOT, DBRPSW) or event("ERR: Can't connect to db");

sub dbctl {
	my $cmd = shift;
	my $cdb = shift;
	my $cdbuser = shift;

	#CREATE DROP ADD DEL GRANT REVOKE
	switch ($cmd) {
		case 0	{ $dbh->do("create database $cdb") or event("WNG: Can't create database $cdb") }
		case 1	{ $dbh->do("drop database $cdb") or event("WNG: Can't drop database $cdb") }
		case 2	{	my $tpw = pwgen; $dbh->do("create user \'$cdbuser\'\@\'localhost\' identified by \'$tpw\'") or event("WNG: Can't create user $cdbuser"); return $tpw }
		case 3	{ $dbh->do("drop user \'$cdbuser\'\@\'localhost\' ") or event("WNG: Can't drop user $cdbuser")}
		case 4	{	$dbh->do("grant all privileges on $cdb\.\* to \'$cdbuser\'\@\'localhost\'") or event("WNG: Can't grant on $cdb for $cdbuser")}
		case 5	{	$dbh->do("revoke all on $cdb\.\* from \'$cdbuser\'\@\'localhost\'") or event("WNG: Can't revoke on $cdb for $cdbuser")}
	}
}


#Main

event("Start");

my %ausers;


my @actuids = @{$dbh->selectcol_arrayref("select id from accounts where expire > unix_timestamp(NOW())")};	# actual uids
my @disuids = @{$dbh->selectcol_arrayref("select id from accounts where expire < unix_timestamp(NOW())")};	# unactual uids ?
my @alluids = @{$dbh->selectcol_arrayref("select id from accounts")};																				# all uids ?

#print "$_\n" foreach (@alluids);
print scalar @actuids . "\n";
print scalar @disuids . "\n";
print scalar @alluids . "\n";










#foreach my $i (@auids) {
#	foreach my $f (@$i) {
#		print $i;
#	}

	#print "$i\n"} ;
#}
#while (my $account = $sth->fetchrow_hashref())
#{
#	 $account->{id} . "\n";
	#print Dumper($account);
#}
#print $req->{NUM_OF_FIELDS};
# print Dumper(@auids);










#my $dbh = DBI->connect("DBI:mysql:", "root", "rootpassword");
#$dbh->disconnect(); #

###
### JSON block
###


# # Read JOSN conf
# my $jsonr;
# open (JSON, "<./test.json") or event("ERR: Can't open json\n");
# while (<JSON>) { $jsonr .= $_ } ;
# close JSON;
# event("ERR:Invalid JSON") unless (valid_json ($jsonr));
#
# # Old conf compare
# my $dgst = md5_base64($jsonr);
# my $dgstold;
# sysopen (OLDDGST, "./old.dgst", O_RDWR|O_CREAT) or event("INF: Can't open old dgst\n");
# while (<OLDDGST>) { $dgstold .= $_ }
# if ($dgstold) {
# 	if ($dgst eq $dgstold) {
# 		event("End: Json was not changed");
# #		exit 0; #
# 	}
# }
# seek(OLDDGST, 0, 0);
# truncate OLDDGST, 0 ;
# print OLDDGST $dgst;
# close OLDDGST;
#
# #print $dgst."\n".$dgstold."\n"; #
#
#
#   dbctl(DEL,0,"tester");
#   dbctl(DROP,"test1","123");
#  #dbctl(CREATE,"test1","123");
#  print dbctl(ADD, 0,"tester");
#  #dbctl(GRANT,"test1","tester");
# dbctl(REVOKE,"test1","tester");
#
#
# #for (my $c = 0 ; $c < 10; $c++) {print pwgen()."\n"} ;
#
# open (APACHECONF, ">./apache.conf") or event("ERR: Can't open apache.conf\n");
# open (MYSQLCONF, ">./sql.conf") or event("ERR: Can't open sql.conf\n");
# open (FTPCONF, ">./ftp.conf") or event("ERR: Can't open ftp.conf\n");

# Зarse in hash
# my $jsonp =  parse_json ( $jsonr );

# my @uids;
# for ( my $t = 0; $jsonp->[$t]->{userid}; $t++) {
# 	#print "num:$t\tid:$jsonp->[$t]->{userid}\tsitename: $jsonp->[$t]->{sitename}\tphpver: $jsonp->[$t]->{phpver}\tactive: $jsonp->[$t]->{active}\t";
# 	print APACHECONF "$jsonp->[$t]->{userid}:$jsonp->[$t]->{sitename}:$jsonp->[$t]->{phpver}:$jsonp->[$t]->{active}";  #uid sitename phpver activeflag
# 	print APACHECONF ":" . join(",", @{$jsonp->[$t]->{mirrors}}) . "\n"; #Mirrors list
# 	for (my $c = 0; $jsonp->[$t]->{db}->[$c]->{dbname}; $c++) {
# 			for (my $z = 0; $jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]; $z++) {
# 				#print "db $jsonp->[$t]->{db}->[$c]->{dbname}\tdbuser $jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]\n" ;
# 				print MYSQLCONF "$jsonp->[$t]->{db}->[$c]->{dbname}:$jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]:" . join(",", @{$jsonp->[$t]->{db}->[$c]->{dbuser}}) . ":$jsonp->[$t]->{active}\n" ;
# 				##print " $jsonp->[$t]->{db}->[$c]->{dbname} $jsonp->[$t]->{db}->[$c]->{dbuser}->[$z]\n" ;
# 				##print join(", ", @{$jsonp->[$t]->{db}->[$c]->{dbuser}}) . "\n"; #
# 				#print "dbusers: " . join(", ", @{$jsonp->[$t]->{db}->[$c]->{dbuser}}) . "\n"; #
# 		}
# 	}
# 	print "\n";
# }


#print join(", ", @array); #

# close APACHECONF;
# close MYSQLCONF;
# close FTPCONF;

###
### JSON block end
###


$dbh->disconnect(); #

#print Dumper($jsonp);
#print $jsonr;
#print $jsonp;
event("End");
close LOG;
exit 0;
