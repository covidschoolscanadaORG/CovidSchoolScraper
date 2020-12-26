#!/usr/bin/perl

use strict;
use lib '../lib';
use CovidSchools::BCUpdate;

use constant CACHE_DIR=> '/tmp/BCUpdate';

my $bc = CovidSchools::BCUpdate->new('CACHE_DIR' => CACHE_DIR);
$bc->write_clean_file();

exit 0;

1;

