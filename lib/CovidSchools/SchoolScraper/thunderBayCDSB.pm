package CovidSchools::SchoolScraper::thunderBayCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Thunder Bay CDSB',
	URL      => 'https://www.tbcschools.ca/about/covid-19/outbreak-advisories',
	);
}

sub table_fields {
    return ('School',
	    'Confirmed',
	    'Closed Classrooms',
	    'School Status',
	   );   
}
    1;
