package CovidSchools::SchoolScraper::islandHealth;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'BC',
	DISTRICT => 'Island Health',
	URL      => 'https://www.islandhealth.ca/learn-about-health/covid-19/exposures-schools',
	);
}

sub table_fields {
    return (
	'School Name',
	'Event',
	'Date'
	   );   
}
    1;
