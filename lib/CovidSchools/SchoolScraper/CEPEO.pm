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

# because of invalid certificate errors
sub new_user_agent {
    return LWP::UserAgent->new(
	agent=>'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0',
	ssl_opts => {verify_hostname => 0,
		     SSL_verify_mode => 0x00},
	);
}

1;
