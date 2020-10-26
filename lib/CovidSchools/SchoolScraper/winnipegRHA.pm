package CovidSchools::SchoolScraper::winnipegRHA;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'Manitoba',
	DISTRICT => 'Winnipeg Regional Health Authority',
	URL      => 'https://manitoba.ca/covid19/restartmb/prs/winnipeg/index.html#schooldaycare',
	);
}

sub table_fields {
    return (
	'Location',
	'Dates/Times',
	'Exposure',
	);   
}

1;
