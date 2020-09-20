package CovidSchools::SchoolScraper::haltonDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Halton District School Board',
	URL      => 'https://www.hdsb.ca/students/Pages/Health%20and%20Well-Being/COVID-19/COVID-19-Advisory.aspx#');
}

sub table_fields {
    return ('School',
	    'Confirmed Cases',
	    'Closed Classroom',
	    'Closed School');
}

1;
