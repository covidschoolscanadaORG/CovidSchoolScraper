package CovidSchools::SchoolScraper::cSDCEO;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'CSDC EO',
	URL      => 'https://eohu.ca/fr/covid/eclosions-ecoles',
	);
}

sub table_fields {
    return (
	'ÉCOLE',
	'CONSEIL SCOLAIRE',
	'DATE',
	'DATE',
	);   
}
    1;
