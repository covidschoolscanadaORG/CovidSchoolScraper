package CovidSchools::SchoolScraper::niagaraCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Niagara Catholic DSB',
	URL      => 'https://niagaracatholic.ca/covid-19-advisories/',
	);
}

sub table_fields {
    return ('School',
    	   'Confirmed Cases',
	   'Closed Classrooms',
	   'Closure Status');
}

1;
