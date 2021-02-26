package CovidSchools::SchoolScraper::southern;

use 5.006;
use strict;
use warnings;
use Carp 'croak';
use base 'CovidSchools::SchoolScraper::northern';

sub new {
    my $class = shift;
    croak "None of the Manitoba scrapers are working!";
    return $class->CovidSchools::SchoolScraper::new(
	PROVINCE => 'Manitoba',
	DISTRICT => 'Southern Health-Santè Sud',
	URL      => 'http://www.manitoba.ca/covid19/restartmb/prs/southern/index.html#exposure',
	);
}


1;
