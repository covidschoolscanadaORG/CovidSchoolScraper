package CovidSchools::SchoolScraper::trilliumLakelandsDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Trillium-Lakelands DSB',
	URL      => 'https://www.tldsb.ca/covid19-advisory/',
	);
}

sub table_fields {
    return (
	'School Name',
	'Confirmed student',
	'Confirmed staff',
	'Closed classrooms',
	'Closure Status',
	   );   
}
    1;
