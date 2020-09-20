package CovidSchools::SchoolScraper::torontoDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Toronto DSB',
	URL      => 'https://www.tdsb.on.ca/Return-to-School/covid-19-advisories'
	);
}

sub table_fields {
    return ('School',
	    'Confirmed Cases Among Students',
	    'Confirmed Cases Among Staff',
	    'Open / Closed');
}

1;
