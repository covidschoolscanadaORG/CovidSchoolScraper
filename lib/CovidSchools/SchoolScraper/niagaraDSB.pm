package CovidSchools::SchoolScraper::niagaraDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Niagara DSB',
	URL      => 'https://www.dsbn.org/covid-19-information/covid-19-public-advisory',
	);
}

sub table_fields {
    return ('School Name',
	    'Confirmed Cases',
	    'Closed Classrooms',
	    'School Closure Status',
	    'Date Of Confirmed Positive',
	);
}

1;
