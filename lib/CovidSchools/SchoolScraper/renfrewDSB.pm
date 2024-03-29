package CovidSchools::SchoolScraper::renfrewDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Renfrew County DSB',
	URL      => 'http://www.rcdsb.on.ca/en/parents/covid-19-school-updates.asp',
	);
}

sub table_fields {
    return ('.+Schools',
	    'Status');
}

1;
