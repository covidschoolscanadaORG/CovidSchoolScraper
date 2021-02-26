package CovidSchools::SchoolScraper::interlakeEastern;

use 5.006;
use strict;
use warnings;
use Carp 'croak';
use base 'CovidSchools::SchoolScraper::northern';

sub new {
    my $class = shift;
    croak "This district does not return a <table> and requires special parsing";
    return $class->CovidSchools::SchoolScraper::new(
	PROVINCE => 'Manitoba',
	DISTRICT => 'Interlake Eastern',
	URL      => 'https://experience.arcgis.com/experience/611bde4f5cd644629f428f0ccf9c9498/page/page_1/',
	);
}


1;
