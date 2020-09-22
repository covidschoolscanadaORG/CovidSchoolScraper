#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";
use CovidSchools::SchoolScraper;

# unsuccessful attempt to get rid of weird chars
# use feature 'unicode_strings';
# binmode STDOUT,":encoding(UTF-8)";

my $subclass = shift || print_error_message_and_die();

eval "use CovidSchools::SchoolScraper::$subclass; 1" or die "Can't load class $subclass";

my $ss = "CovidSchools::SchoolScraper::$subclass"->new();
$ss->scrape() or die $ss->error;
print $ss->csv,"\n";
# print $ss->raw_content,"\n";


exit 0;

sub print_error_message_and_die {
    my $modules = join "\n   ",CovidSchools::SchoolScraper->board_subclasses;
    $modules   =~ s/CovidSchools::SchoolScraper:://gm;
    die <<END;
Usage: $0 <scraper module>
Current scraper modules are:
   $modules
END
}
