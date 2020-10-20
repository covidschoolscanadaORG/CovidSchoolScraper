package CovidSchools::SchoolScraper::waterlooRegionalDSB;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraper';


sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Waterloo Regional DSB',
	URL      => 'https://www.wrdsb.ca/our-schools/health-and-wellness/public-health-information/novel-coronavirus-covid-19-information/confirmed-cases-of-covid-19/'
	);
}

sub table_fields {
    return ('Date','Location','Staff or Student');
}

1;
