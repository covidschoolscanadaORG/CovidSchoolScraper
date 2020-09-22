#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use constant SCRAPEDIR=>'./scraped_data';

chdir "$Bin/..";   # go up one level from where we are stored
my $scrapedir = SCRAPEDIR;
my $mergedir  = SCRAPEDIR . '/MERGED_DAILY';
mkdir $scrapedir unless -e $scrapedir;
mkdir $mergedir  unless -e $mergedir;

system "./script/scrapeSchools.pl      $scrapedir";
system "./script/scrapeSchoolsBatch.pl $mergedir";
system "rclone copy $scrapedir dsb_snapshots:";

exit 0;
