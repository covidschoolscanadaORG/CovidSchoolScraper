package CovidSchools::SchoolScraper::interlakeEastern;

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
	DISTRICT => 'Interlake Eastern',
	URL      => 'https://experience.arcgis.com/experience/611bde4f5cd644629f428f0ccf9c9498/page/page_1/',
	);
}


1;
