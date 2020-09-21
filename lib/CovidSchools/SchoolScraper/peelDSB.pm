package CovidSchools::SchoolScraper::peelDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraperPuppeteer';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Peel DSB',
	URL      => 'https://www.peelschools.org/covid19-advisory/Pages/default.aspx',
	);
}

sub table_fields {
    return ('School Name',
    	   'Confirmed Cases',
	   'Closed Classrooms',
	   'Closure Status');
}

1;
