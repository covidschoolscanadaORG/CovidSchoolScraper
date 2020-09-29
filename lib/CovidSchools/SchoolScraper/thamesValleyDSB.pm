package CovidSchools::SchoolScraper::thamesValleyDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Thames Valley DSB',
	URL      => 'https://www.tvdsb.ca/en/our-board/covid-19-alerts.aspx',
	);
}

sub table_fields {
    return (
	'School Name',
	'Confirmed Cases',
	'Closed Classes',
	'Closure Status',
	);   
}

# because of server key size problems
sub new_user_agent {
    return LWP::UserAgent->new(
	ssl_opts => {
	    SSL_cipher_list => 'DEFAULT:!DH'
	},
	);
}

1;
