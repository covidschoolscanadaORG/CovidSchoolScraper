package CovidSchools::SchoolScraper::simcoeCountyDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Simcoe County DSB',
	URL      => 'https://www.scdsb.on.ca/covid-19/advisory_board'
	);
}

sub clean_text {
    my $self = shift;
    my $t    = shift;
    $self->SUPER::clean_text($t);
    $$t =~ s/&nbsp;/ /g;
    $$t =~ s/\s+/ /g;
}

sub table_fields {
    return ('Site',
	    'Confirmed',
	    'Closed',
	    'status',
	);
}

1;
