package CovidSchools::SchoolScraper::dufferinPeelCatholicDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Dufferin-Peel Catholic DSB',
	URL      => 'https://www3.dpcdsb.org/news/news-archives/community-advisory-reporting',
	);
}

sub table_fields {
    return ('School Name',
	    'Confirmed Cases',
	    'Closed Classrooms',
	    'Closure Status');
}

# because of certificate problems
sub new_user_agent {
    return LWP::UserAgent->new(
	agent=>'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0',
	ssl_opts => {verify_hostname => 0,
		     SSL_verify_mode => 0x00},
	);
}
1;
