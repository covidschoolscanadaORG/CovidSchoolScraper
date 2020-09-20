#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'CovidSchools::SchoolScraper' ) || print "Bail out!\n";
}

diag( "Testing CovidSchools::SchoolScraper $CovidSchools::SchoolScraper::VERSION, Perl $], $^X" );
