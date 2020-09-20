#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";

use CovidSchools::SchoolScraper;
use DateTime;
use File::Basename 'basename','dirname';
use File::Path 'make_path';
use IO::Dir;

my $DATADIR = shift or die "Usage: scrapeSchools.pl <destination directory>";

my @s = CovidSchools::SchoolScraper->board_subclasses;
for my $subclass (@s) {
    eval "use $subclass; 1" or die $@;
    my $dsb = $subclass->new();
    my $dest_file = scrape_and_save($dsb);
    generate_diff($dest_file);
}

exit 0;

sub scrape_and_save {
    my $dsb = shift;
    $dsb->scrape();

    my $dest_file = dest_csv_path($dsb);
    open my $fh,'>',"$dest_file" or die "$dest_file: $!";
    print $fh $dsb->csv;
    close $fh                    or die "$dest_file: $!";
    return $dest_file;
}

sub generate_diff {
    my $dest_file  = shift;
    die "$dest_file doesn't exist" unless -e $dest_file;
    my $prior_file = find_previous($dest_file);
    return unless -e $prior_file;
    my $dir        = dirname($dest_file);
    my $diff_file  = $dir.'/'.basename($dest_file,'.csv').'.diff';
    system "diff -c '$prior_file' '$dest_file' > '$diff_file'";
}

sub find_previous {
    my $dest_file = shift;
    my $mtime     = (stat($dest_file))[9];
    my $dir       = dirname($dest_file);

    # open directory and find previous file
    my $d         = IO::Dir->new($dir);
    defined $d or return;
    my %listing;
    while (defined($_ = $d->read)) {
	next if /^\./;
	my $time  = (stat("$dir/$_"))[9];
	$listing{$_} = $time;
    }

    my @sorted = sort {$listing{$a} <=> $listing{$b}} keys %listing;
    my $last = $_;
    for (my $i=0;$i<@sorted && $listing{$sorted[$i]} < $mtime; $i++) {
	$last = $i;
    }

    return unless $last < $#sorted;
    return $dir.'/'.$sorted[$last];
}

sub dest_csv_path {
    my $dsb = shift;
    my $date = DateTime->now(time_zone=>'local')->set_time_zone('floating');

    my $dest_dir = "$DATADIR/".$dsb->district;
    make_path($dest_dir) or die "Couldn't create path to $dest_dir: $!"
	unless -e $dest_dir;

    return "$dest_dir/$date.csv";
}



