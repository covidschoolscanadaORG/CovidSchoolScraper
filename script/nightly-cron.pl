#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use constant SCRAPEDIR=>'./scraped_data';

chdir "$Bin/..";   # go up one level from where we are stored
my $scrapedir = SCRAPEDIR;
mkdir $scrapedir unless -e $scrapedir;

system "./script/scrapeSchools.pl $scrapedir";
system "rclone copy $scrapedir dsb_snapshots:";

exit 0;
