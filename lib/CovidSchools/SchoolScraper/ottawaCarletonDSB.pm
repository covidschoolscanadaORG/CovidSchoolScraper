package CovidSchools::SchoolScraper::ottawaCarletonDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Ottawa-Carleton DSB',
	URL      => 'https://ocdsb.ca/cms/One.aspx?portalId=55478&pageId=33161200',
	);
}

sub table_fields {
    return ('School',
	    'student',
	    'staff',
	    'Classes closed',
	    'Cohorts closed',
	    'Schools closed');
}

1;
