package CovidSchools::SchoolScraper::interlakeEastern;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper::northern';

sub new {
    my $class = shift;
    return $class->CovidSchools::SchoolScraper::new(
	PROVINCE => 'Manitoba',
	DISTRICT => 'Interlake Eastern',
	URL      => 'http://www.manitoba.ca/covid19/restartmb/prs/interlake_eastern/index.html#exposure',
	);
}


1;
