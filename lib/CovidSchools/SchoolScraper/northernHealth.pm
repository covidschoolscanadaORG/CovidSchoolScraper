package CovidSchools::SchoolScraper::northernHealth;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'BC',
	DISTRICT => 'Northern Health',
	URL      => 'https://www.northernhealth.ca/health-topics/public-exposures-and-outbreaks#covid-19-school-exposures#covid-19-school-exposures#covid-19-public-exposures',
	);
}

sub table_fields {
    return (
	'SCHOOL DISTRICT',
	'SCHOOL NAME',
	'EVENT',
	'EXPOSURE DATE'
	   );   
}
    1;
