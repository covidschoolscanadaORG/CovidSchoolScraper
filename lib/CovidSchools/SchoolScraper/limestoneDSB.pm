package CovidSchools::SchoolScraper::limestoneDSB;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraper';


sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Limestone DSB',
	URL      => 'https://www.limestone.on.ca/cms/One.aspx?portalId=352782&pageId=28825834',
	);
}

sub table_fields {
    return ('Date','School/Site','Confirmed','Closure Status');
}

1;
