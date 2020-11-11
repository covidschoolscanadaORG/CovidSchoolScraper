package CovidSchools::SchoolScraper::torontoDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Toronto DSB',
	#	URL      => 'https://www.tdsb.on.ca/Return-to-School/covid-19-advisories'
	URL => 'https://docs.google.com/spreadsheets/d/1gEipMl79REabV5GPuJnPeziC3DbYhA92U_BxpzdKX_Y/htmlembed/sheet?gid=0&',
	);
}

sub table_fields {
    return (
	'School',
	'Students',
	'Staff',
	'Resolved',
	'Open'
	);
}

1;
