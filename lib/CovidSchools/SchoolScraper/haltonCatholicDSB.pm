package CovidSchools::SchoolScraper::haltonCatholicDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Halton Catholic DSB',
	URL      => 'https://learnathome.hcdsb.org/covid-19-advisory-board/?fbclid=IwAR2uBPRO5IFyB5WT_Gw5aTT8N59xwvt-U_DMHOrE46RjGP1PVa2ZuwVE7nQ',
	);
}

sub table_fields {
    return ('School Name',
	    'Confirmed Cases',
	    'Closed Classrooms',
	    'Closure Status');
}

1;
