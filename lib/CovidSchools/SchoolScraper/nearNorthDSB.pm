package CovidSchools::SchoolScraper::nearNorthDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'Ontario',
	DISTRICT => 'Near North DSB',
	URL      => 'https://www.nearnorthschools.ca/blog/covid-19-updates-and-resources/20656/',
	);
}

sub table_fields {
    return (
	'School',
	'Active',
	'Total',
	'Resolved',
	'Outbreak',
	'Status',
	'Date',
	)
}



1;
