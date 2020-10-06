package CovidSchools::SchoolScraper::ottawaCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Ottawa CDSB',
	URL      => 'https://docs.google.com/spreadsheets/u/1/d/e/2PACX-1vRQsBHwiBDWRcgxGF0mXnh1KrtKTAROmfODhMmagkW3R5kJYkE007SMAE-DmBm-77ixitCY4vlSQLRI/pubhtml?gid=0&single=true',
	);
}

sub table_fields {
    return (
	'School Name',
	'Current student',
	'Current staff',
	'Current cohorts',
	'Schools currently closed'
	   );   
}
    1;
