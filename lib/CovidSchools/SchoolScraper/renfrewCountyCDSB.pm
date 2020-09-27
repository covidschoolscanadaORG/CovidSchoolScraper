package CovidSchools::SchoolScraper::renfrewCountyCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Renfrew County CDSB',
	URL      => 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTZJbWH4nncBME67xh53A1BIO72fzz_izVs9T43wU_eRKtcCQo79qXm801PO4DKhheD9wy0i4tQhWam/pubhtml',
	);
}

sub table_fields {
    return (
	'School Name',
	'Confirmed student',
	'Confirmed staff',
	'Classes closed',
	'Cohorts closed',
	'School closed',
	   );   
}
    1;
