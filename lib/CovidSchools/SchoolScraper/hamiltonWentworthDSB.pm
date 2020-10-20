package CovidSchools::SchoolScraper::hamiltonWentworthDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Hamilton-Wentworth DSB',
	URL      => 'https://www.hwdsb.on.ca/about/covid19/confirmed-cases-of-covid-19/',
	);
}

sub table_fields {
    return (
	'Date',
	'Location',
	'Staff or Student',
	   );   
}
    1;
