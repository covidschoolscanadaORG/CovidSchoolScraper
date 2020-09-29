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

# filter out non-schools
sub csv {
    my $self = shift;
    
    my $csv = '';
    $csv   .= $self->header;
    my $table = $self->{raw_content};
    $table    =~ s/,\s*$//gm;  # remove pesky trailing commas
    my @rows  = grep {/school|Facility Type/i} split "\n",$table;
    $csv .= join "\n",@rows;
    $csv;
}

1;
