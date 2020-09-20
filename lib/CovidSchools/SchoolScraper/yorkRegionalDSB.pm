package CovidSchools::SchoolScraper::yorkRegionalDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'York Regional DSB',
	URL      => 'http://www.yrdsb.ca/schools/school-reopening/Pages/COVID19-Advisory-Board.aspx',
	);
}

sub table_fields {
    return ('School Name',
	    '.+ Cases',
	    'Closed Classrooms',
	    'Closure Status'
	);
}

1;
