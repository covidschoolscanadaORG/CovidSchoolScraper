package CovidSchools::SchoolScraper::waterlooCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Waterloo CDSB',
	URL      => 'https://www.wcdsb.ca/covid-19-advisories/',
	);
}

sub table_fields {
    return (
	'Location',
	'Date',
	'Staff or Student',
	);   
}
1;
