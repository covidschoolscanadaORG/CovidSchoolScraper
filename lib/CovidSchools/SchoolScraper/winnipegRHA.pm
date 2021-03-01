package CovidSchools::SchoolScraper::winnipegRHA;

use 5.006;
use strict;
use warnings;
use Carp 'croak';
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    croak "None of the Manitoba scrapers are working due to a recent change in table format.";
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
