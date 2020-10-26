package CovidSchools::SchoolScraper::fraserHealth;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraper';


sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'BC',
	DISTRICT => 'Fraser Health',
	URL      => 'https://www.fraserhealth.ca/schoolexposures#.X47h-XVJFhG',
	);
}

sub table_fields {
    return ('School',
	    'Exposure',
	    'Date',
	);
}

1;
