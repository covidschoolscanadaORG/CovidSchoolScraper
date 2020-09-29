package CovidSchools::SchoolScraper::cECCE;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Écoles catholiques Centre-Est (CECCE)',
	URL      => 'https://www.ecolecatholique.ca/fr/Cas-De-Covid19_379',
	);
}

sub table_fields {
    return (
	'Écoles',
	'Cas actifs',
	);   
}
    1;
