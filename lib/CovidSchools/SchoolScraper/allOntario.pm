package CovidSchools::SchoolScraper::allOntario;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraperPuppeteer';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Ontario COVID-19 Summary',
	URL      => 'https://www.ontario.ca/page/covid-19-cases-schools-and-child-care-centres');
}

sub table_fields {
    return ('School',
	    'School Board',
	    'Municipality',
	    'staff cases',
	    'individual(s)',
	    'Total'
	);
}

1;
