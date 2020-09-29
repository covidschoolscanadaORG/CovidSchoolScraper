package CovidSchools::SchoolScraper::superiorNorthCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Superior North CDSB',
	URL      => 'http://www.sncdsb.on.ca/covid-19-cases-sncdsb',
	);
}

sub table_fields {
    return ('School Name',
	    'Confirmed Student',
	    'Confirmed Staff',
	    'Closed Classes',
	    'School Status',
	   );   
}
    1;
