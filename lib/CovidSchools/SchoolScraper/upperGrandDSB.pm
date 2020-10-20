package CovidSchools::SchoolScraper::upperGrandDSB;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraper';


sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Upper Grand DSB',
	URL      => 'https://www.ugdsb.ca/community/coronavirus/reopening-schools-plan/covid-19-advisory-reporting/',
	);
}

sub table_fields {
    return ('School Name',
	    'Confirmed Cases',
	    'Closed Classrooms',
	    'Closure Status',
	);
}

1;
