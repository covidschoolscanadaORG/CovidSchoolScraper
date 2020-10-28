#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use DateTime;
use constant SCRAPEDIR=>'./scraped_data';
use constant GITHUBIO =>'../covidschoolscanada.github.io';

use constant BACKUP_SITE=>'dropbox:SchoolBoard_daily_snapshot';
# use constant DESTINATION=>'dsb_snapshots:';

chdir "$Bin/..";   # go up one level from where we are stored
my $scrapedir = SCRAPEDIR;
mkdir $scrapedir unless -e $scrapedir;

my $ts = DateTime->now(time_zone=>'local')->set_time_zone('floating')->strftime('%Y-%m-%dT%H%M');

print "================== nightly scrape $ts ==================\n";

system "./script/scrapeSchools.pl       $scrapedir";
if ($? == -1) {
    die "Aborting due to previous errors";
}
system "./script/schoolScraperToHTML.pl $scrapedir > $scrapedir/SUMMARY-$ts.html";
system 'rclone','copy',$scrapedir,BACKUP_SITE;
system "./script/update-covidschoolscanada-io.pl",GITHUBIO;
chdir "../covidschoolscanada.github.io";
system "git add daily_reports";
system "git commit -a -m'daily advisory update, $ts'";

# for git push to work, need to have the ssh-user-agent environment variable set
# correctly. otherwise it fails for lack of credentials
system "git pull";
system "git push";

exit 0;
