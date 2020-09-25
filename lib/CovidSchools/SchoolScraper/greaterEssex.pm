package CovidSchools::SchoolScraper::greaterEssex;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Greater Essex',
	URL      => 'https://www.publicboard.ca/News/COVID-19Report/Pages/default.aspx#/=');
}

sub table_fields {
    return ('School',
	    'Cases',
	    'Number',
	);
}

sub create_extractor {
    my $self = shift;
    HTML::TableExtract->new(headers      => $self->column_headers,
			    keep_headers => 1,
			    slice_columns => 0,
			    debug        => 0,
	);
}

sub clean_text {
    my $self = shift;
    my $text = shift;
    $$text =~ s/[^\x00-\x7f]//g;
}


1;
