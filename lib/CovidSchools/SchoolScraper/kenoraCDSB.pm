package CovidSchools::SchoolScraper::kenoraCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Kenora CDSB',
	URL      => 'https://www.kcdsb.on.ca/news/central_news/c_o_v_i_d-19_a_d_v_i_s_o_r_i_e_s',
	);
}

sub table_fields {
    return (
	'School Name',
	'Confirmed Cases',
	'Closed Classrooms',
	'School Status',
	   );   
}
    1;
