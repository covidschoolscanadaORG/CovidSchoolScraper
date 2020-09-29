package CovidSchools::SchoolScraper::durhamDSB;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraperTable';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Durham DSB',
	URL      => 'https://docs.google.com/spreadsheets/d/1YBn91VaM5IqGhJ_OvShCIpoohIRc2yFI0OwYzBaEe20/export?format=csv&gid=0',
	);
}


1;
