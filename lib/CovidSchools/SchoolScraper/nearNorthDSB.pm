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
	URL      => 'https://www.nearnorthschools.ca/blog/transition-to-school-resources/23515/',
	);
}

sub table_fields {
    return (
	'School',
	'Active',
	'Total',
	'Resolved',
	'Outbreak',
	'Class',
	'Date',
	)
}



1;
