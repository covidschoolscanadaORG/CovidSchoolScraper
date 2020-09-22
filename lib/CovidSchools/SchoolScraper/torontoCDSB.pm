package CovidSchools::SchoolScraper::torontoDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Toronto_CDSB',
	URL      => 'https://www.tcdsb.org/FORSTUDENTS/back-to-school/Pages/confirmed-covid-cases.aspx'
	);
}

sub table_fields {
    return ('School Name',
	    'Student or Staff (#)',
	    'School Status');
}

1;
