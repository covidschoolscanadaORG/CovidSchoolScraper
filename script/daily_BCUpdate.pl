#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";
use CovidSchools::BCUpdate;
use File::Temp 'tempdir';

use constant CACHE_DIR=> '/tmp/BCUpdateCache';
use constant GDRIVE   => '/BC';

mkdir CACHE_DIR unless -e CACHE_DIR;
my $bc = CovidSchools::BCUpdate->new(CLEAN_CSV => "$ENV{HOME}/Dropbox/BC_Automation/daily_update",
				     'CACHE_DIR' => CACHE_DIR,
    );

print STDERR "Downloading latest BC tracker table\n";
my $table = $bc->get_grassroots_tracker_table();

# Mount google drive temporarily to store supporting documentation
print STDERR "Mounting Google drive to collect documentation\n";
my $dest = tempdir(CLEANUP=>0);
system 'rclone','--drive-shared-with-me','mount','--daemon','gdrive:'.GDRIVE,$dest;

my $tries = 0;
until (-e "$dest/.mounted") {
    die "Couldn't mount google drive" if $tries++ > 10;
    sleep 1;
}

print STDERR "Writing out copy of parsed tracker file\n";
$bc->write_tracker_file($table);

print STDERR "Mirroring documentation\n";
$bc->mirror_articles($table,$dest);

print STDERR "Writing out clean CSV file\n";
$bc->write_clean_file($table);

exit 0;

1;

END {
    system "sync";
    sleep 1;
    system "sync";
    system "fusermount -u $dest";
    rmdir $dest;
}
