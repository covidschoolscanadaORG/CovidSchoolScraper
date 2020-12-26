#!/usr/bin/perl

use strict;
use lib '../lib';
use CovidSchools::BCUpdate;

use constant CACHE_DIR=> '/tmp/BCUpdate';

my $bc = CovidSchools::BCUpdate->new('CACHE_DIR' => CACHE_DIR);
my $aa = $bc->get_grassroots_tracker_table();

for my $row (@$aa) {
    my $school = $row->[1];
    print $school,"\n" unless $bc->bc_schoolname_to_code($school);
}

exit 0;

1;

