package CovidSchools::SchoolScraper::kawarthaPineRidge;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Kawartha Pine Ridge',
	URL      => 'http://kprschools.ca/en/COVID19Reporting.html',
	);
}

sub table_fields {
    return (
	'School Name',
	'Confirmed Student',
	'Confirmed Staff',
	'Status',
	);   
}
    1;
