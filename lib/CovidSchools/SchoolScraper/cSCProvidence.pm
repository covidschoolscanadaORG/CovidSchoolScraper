package CovidSchools::SchoolScraper::cSCProvidence;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'CSC Providence',
	URL      => 'https://cscprovidence.ca/parents/rentree-scolaire-2020/avis-de-fermeture',
	);
}

sub table_fields {
    return (
	"NOM DE L'ÉCOLE",
	'CONFIRMÉS',
	'ACTIVES',
	'FERMETURE',
	   );   
}
    1;
