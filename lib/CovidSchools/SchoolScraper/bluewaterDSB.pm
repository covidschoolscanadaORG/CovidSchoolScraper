package CovidSchools::SchoolScraper::bluewaterDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'Ontario',
	DISTRICT => 'Bluewater DSB',
	URL      => 'https://www.bwdsb.on.ca/Parents/COVID-19_Advisories'
	);
}

sub table_fields {
    return (
	'Date',
	'Location',
	'Student/Staff',
	)
}


1;
