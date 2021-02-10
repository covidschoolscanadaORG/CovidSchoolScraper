package CovidSchools::SchoolScraper::kawarthaPineRidge;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Kawartha Pine Ridge',
	URL      => 'https://www.kprschools.ca/en/COVID19Reporting.html',
	);
}

sub parsed_headers {
    ['School Name',
     'Active Confirmed Cases of COVID-19',
     'Status'
    ]
}

sub table_fields {
    return (
	'School Name',
	'Confirmed',
	'Status',
	);   
}
    1;
