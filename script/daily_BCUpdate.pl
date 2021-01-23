#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";
use CovidSchools::BCUpdate;
use File::Temp 'tempdir';
use Fcntl;
use DB_File;

#use constant CACHE_DIR=> '/tmp/BCUpdateCache';
use constant CACHE_DIR => "$Bin/../scraped_data/BCUpdateCache";
use constant GDRIVE    => '/BC';

mkdir CACHE_DIR unless -e CACHE_DIR;

# open/create DB_File to cache GDrive path to URL info
my %GDriveCache;
tie %GDriveCache,'DB_File',CACHE_DIR.'/GDriveCache.db',O_CREAT|O_RDWR,0666,$DB_HASH
    or die "Cannot open dbfile: $!";

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
$bc->mirror_articles($table,$dest,\%GDriveCache,\&make_gdrive_url);

print STDERR "Writing out clean CSV file\n";
$bc->write_clean_file($table);

exit 0;

sub make_gdrive_url {
    my $gdrive_path = shift;
    return $GDriveCache{$gdrive_path} if $GDriveCache{$gdrive_path};
    my $url;
    my $tries = 0;
    while (!$url && $tries++ < 5) {
	$url = `rclone --drive-shared-with-me link "gdrive:$gdrive_path" 2>/dev/null`;
	chomp $url;
	unless ($url) {
	    sleep 1;
	    system "sync";
	}
    }
    print STDERR $tries if $tries > 1;
    $GDriveCache{$gdrive_path} = $url if $url;
    return $url;
}

1;



END {
    system "sync";
    sleep 1;
    system "sync";
    if ($dest) {
	system "fusermount -u $dest";
	rmdir $dest;
    }
    if (%GDriveCache) {
	untie %GDriveCache;
    }
}
