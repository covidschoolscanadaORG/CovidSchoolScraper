package CovidSchools::SchoolScraper::sosAlberta;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'SOS Alberta',
	PROVINCE => 'Alberta',
	URL      => 'https://docs.google.com/spreadsheets/u/0/d/e/2PACX-1vQFuV2axZbkauJv8p09CnIPeBQuI_5A1CluMOZwvI1uwgN5x98MXjFEMkeFHjdRb55oMuW9TFhS5Inn/pubhtml/sheet?headers=false&gid=0',
	);
}

sub table_fields {
    return (
	'School',
	'Town',
	'Range',
	'Report',
	'To Date',
	'AHS',
	'Code',
	'Status',
    );
}


1;
