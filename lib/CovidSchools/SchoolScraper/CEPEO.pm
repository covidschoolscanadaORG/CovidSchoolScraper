package CovidSchools::SchoolScraper::CEPEO;

use 5.006;
use strict;
use warnings;
use feature 'unicode_strings';
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => "Conseil des écoles publiques de l'Est de l'Ontario (CEPEO)",
	URL      => 'https://cepeo.on.ca/retouralecole/depistage-quotidien-des-eleves-cas-et-symptomes-covid-19/',
	);
}

sub table_fields {
    return (
	'Écoles',
	'Cas actifs',
	'Cas actifs',
	'Classes fermées',
	'Cohortes fermées',
	'Écoles fermées',
	'Cas résolus',
	);
}

1;
