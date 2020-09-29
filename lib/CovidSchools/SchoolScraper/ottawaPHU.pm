package CovidSchools::SchoolScraper::ottawaPHU;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraperTable';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Ottawa PHU',
	URL      => 'https://www.arcgis.com/sharing/rest/content/items/5b24f70482fe4cf1824331d89483d3d3/data',
	);
}

1;
