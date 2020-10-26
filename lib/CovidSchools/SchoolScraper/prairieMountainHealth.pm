package CovidSchools::SchoolScraper::prairieMountainHealth;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper::northern';

sub new {
    my $class = shift;
    return $class->CovidSchools::SchoolScraper::new(
	PROVINCE => 'Manitoba',
	DISTRICT => 'Prairie Mountain Health',
	URL      => 'http://www.manitoba.ca/covid19/restartmb/prs/prairie_mountain/index.html#exposure',
	);
}


1;
