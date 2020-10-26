package CovidSchools::SchoolScraper::saskatchewanPHU;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'Saskatchewan',
	DISTRICT => 'Saskatchewan PHU',
	URL      => 'https://www.saskatchewan.ca/government/health-care-administration-and-provider-resources/treatment-procedures-and-guidelines/emerging-public-health-issues/2019-novel-coronavirus/latest-updates#advisories-events-locations',
	);
}

sub table_fields {
    return (
	'Name',
	'Location',
	'Zone',
	'Date Declared',
	'Other Information',
	);   
}

sub _tables {
    my $self = shift;
    my $te   = shift;
    ($te->tables)[0]; # first table only
}

1;
