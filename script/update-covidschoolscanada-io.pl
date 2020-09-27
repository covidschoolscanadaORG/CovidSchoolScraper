#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";
use IO::Dir;
use File::Copy;
use File::Basename 'basename';
use Date::Parse;
use DateTime;

my $io_pages = shift || "$Bin/../../covidschoolscanada.github.io";
-d $io_pages or die "io_pages/ in path";

my $daily_summaries = "$io_pages/daily_reports";
-d $daily_summaries or die "Can't find $daily_summaries/ in path";

my $summary_source = "$Bin/../scraped_data/";
-d $summary_source or die "Can't find $summary_source/ in path";

# Regenerate the summary page
open my $fh,'>',"$daily_summaries/index.md" or die "$daily_summaries/index.md: $!";
print $fh <<END;
---
layout: page
title: School Board Daily Advisory Updates
---

Each update below compares the current day to the previous day:
END
    ;

my @summaries;

my $d = IO::Dir->new($summary_source);
while (defined ($_ = $d->read)) {
    next unless /^SUMMARY-.+/;
    push @summaries,"$summary_source/$_";
}
undef $d;

# sort summaries reverse alphabetically, which will put more recent first
# (if nobody mucks with the naming convention!!!)
@summaries = sort {$b cmp $a} @summaries;

for my $s (@summaries) {
    my $basename = basename($s);
    copy($s,"$daily_summaries/$basename") or die "Copy failed: $!";
    (my $link_name = $basename) =~ s/^SUMMARY-//;
    $link_name                  =~ s/T\d.+$//;
    my $dow                     = find_dow($link_name);
    print $fh "1. [$link_name ($dow)]($basename)\n";
}

close $fh or die "Error while closing index.md: $!";
exit 0;


sub find_dow {
    my $ts  = str2time(shift);
    my $dow = DateTime->from_epoch(epoch=>$ts,time_zone=>'local')->set_time_zone('floating')->day_of_week;
    return (('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')[$dow]);
}
