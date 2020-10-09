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

sub parsed_headers {
    ['School Name',
     'Active Confirmed Student Cases of COVID-19',
     'Active Confirmed Staff Cases of COVID-19',
     'Status']
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
