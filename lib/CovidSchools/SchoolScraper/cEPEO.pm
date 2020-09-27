package CovidSchools::SchoolScraper::cEPEO;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'CEPEO',
	URL      => 'https://cepeo.on.ca/retouralecole/depistage-quotidien-des-eleves-cas-et-symptomes-covid-19/',
	);
}

sub table_fields {
    return ('School',
	    # FILL IN MISSING
	   );   
}
    1;
