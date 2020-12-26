#!/usr/bin/perl

use strict;
use lib '../lib';
use CovidSchools::BCUpdate;
use Text::CSV 'csv';

use constant CACHE_DIR=> '/tmp/BCUpdate';

my $bc = CovidSchools::BCUpdate->new('CACHE_DIR' => CACHE_DIR);
my $aa = $bc->get_grassroots_tracker_table();

csv(in=>$aa,out=>\*STDOUT,sep_char=>",");

exit 0;

1;

