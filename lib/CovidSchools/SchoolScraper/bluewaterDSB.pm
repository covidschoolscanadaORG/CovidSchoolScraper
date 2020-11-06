package CovidSchools::SchoolScraper::bluewaterDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'Ontario',
	DISTRICT => 'Bluewater DSB',
	URL      => 'https://bwdsb.ss14.sharpschool.com/cms/One.aspx?portalId=8166184&pageId=12519920'
	);
}

sub table_fields {
    return (
	'Date',
	'Location',
	'Student/Staff',
	)
}


1;
