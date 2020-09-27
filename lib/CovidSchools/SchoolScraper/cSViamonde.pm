package CovidSchools::SchoolScraper::cSViamonde;

use 5.006;
use strict;
use warnings;
use Encode 'encode','decode';
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'CS Viamonde',
	URL      => 'https://csviamonde.ca/retour-a-lecole/depistage-de-la-covid-19/',
	);
}

sub table_fields {
    return (
	'Élèves',
	'Membres du personnel'
	);   
}

# workarounds for broken table
sub parsed_headers {
    my $headers = shift->SUPER::parsed_headers;
    $headers->[0] = decode('UTF-8'=>'Établissement');
    return $headers;
}

sub create_extractor {
    my $self = shift;
    HTML::TableExtract->new(headers      => $self->column_headers,
			    keep_headers => 1,
			    slice_columns => 0,
			    debug        => 0,
			    decode       => 0,
	);
}

1;
