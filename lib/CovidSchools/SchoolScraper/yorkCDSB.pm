package CovidSchools::SchoolScraper::yorkCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'York CDSB',
	URL      => 'https://www.ycdsb.ca/reopening/covid19-advisory/',
	);
}

sub table_fields {
    return (
	'School Name',
	'Confirmed Cases',
	'Closed Classrooms',
	'Closure Status',
	   );   
}
    1;
