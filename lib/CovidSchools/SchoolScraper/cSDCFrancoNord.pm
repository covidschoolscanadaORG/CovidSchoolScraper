package CovidSchools::SchoolScraper::cSDCFrancoNord;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'CSDC Franco-Nord',
	URL      => 'https://www.franco-nord.ca/COVID-19',
	);
}

sub table_fields {
    return (
	'École',
	'Cas déclarés',
	'Guérisons',
	'Éclosions',
	'Fermetures de classes',
	   );   
}
    1;
