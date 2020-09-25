#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use DateTime;
use constant SCRAPEDIR=>'./scraped_data';
use constant DESTINATION=>'dropbox:SchoolBoard_daily_snapshot';

chdir "$Bin/..";   # go up one level from where we are stored
my $scrapedir = SCRAPEDIR;
mkdir $scrapedir unless -e $scrapedir;

my $ts = DateTime->now(time_zone=>'local')->set_time_zone('floating');

system "./script/scrapeSchools.pl       $scrapedir";
system "./script/schoolScraperToHTML.pl $scrapedir > $scrapedir/SUMMARY-$ts.html";
#system "rclone copy $scrapedir ".DESTINATION;

exit 0;
