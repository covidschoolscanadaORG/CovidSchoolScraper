package CovidSchools::SchoolScraper::prairieMountainHealth;

use 5.006;
use strict;
use warnings;
use Carp 'croak';
use base 'CovidSchools::SchoolScraper::northern';

sub new {
    my $class = shift;
    croak "None of the Manitoba scrapers are working due to a recent change in table format.";
    return $class->CovidSchools::SchoolScraper::new(
	PROVINCE => 'Manitoba',
	DISTRICT => 'Prairie Mountain Health',
	URL      => 'http://www.manitoba.ca/covid19/restartmb/prs/prairie_mountain/index.html#exposure',
	);
}


1;
