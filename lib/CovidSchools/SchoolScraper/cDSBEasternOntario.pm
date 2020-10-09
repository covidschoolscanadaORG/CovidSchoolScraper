package CovidSchools::SchoolScraper::cDSBEasternOntario;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'CDSB Eastern Ontario',
	URL      => 'https://www.cdsbeo.on.ca/students-parents/novel-coronavirus/covid-19-advisory-listing/',
	);
}

sub table_fields {
    return ('School Name',
	    'Date',
	    'Number of Cases',
	    'School Closure',
	   );   
}

sub create_extractor {
    my $self = shift;
    HTML::TableExtract->new(headers      => $self->column_headers,
			    keep_headers => 0,
			    debug        => 0,
			    decode       => 1,
	);
}

1;
