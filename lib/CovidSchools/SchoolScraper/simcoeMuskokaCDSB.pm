package CovidSchools::SchoolScraper::simcoeMuskokaCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Simcoe Muskoka CDSB',
	URL      => 'https://www.smcdsb.on.ca/school_re-_opening/c_o_v_i_d-19_advisory_school_status',
	);
}

sub table_fields {
    return ('School Name',
    	   'Confirmed Cases',
	   'Closed Classrooms',
	   'School Closure Status');
}

1;
