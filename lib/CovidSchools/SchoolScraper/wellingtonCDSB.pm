package CovidSchools::SchoolScraper::wellingtonCDSB;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraper';


sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Wellington Catholic DSB',
	URL      => 'https://www.wellingtoncdsb.ca/apps/pages/index.jsp?uREC_ID=1096071&type=d&pREC_ID=1374893',
	);
}

sub table_fields {
    return ('School',
	    'Confirmed Cases',
	    'Closed Classrooms',
	    'Closure Status',
	);
}

1;
