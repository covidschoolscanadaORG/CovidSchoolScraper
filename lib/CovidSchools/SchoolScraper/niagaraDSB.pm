package CovidSchools::SchoolScraper::niagaraDSB;

use 5.006;
use strict;
use warnings;
use Encode 'decode','encode';
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Niagara DSB',
	URL      => 'https://www.dsbn.org/covid-19-information/covid-19-public-advisory',
	);
}

sub create_extractor {
    my $self = shift;
    HTML::TableExtract->new(headers      => $self->column_headers,
			    keep_headers => 0,
			    slice_columns => 0,
			    decode        => 1,
	);
}

sub table_fields {
    return ('School',
	    'Active Cases',
	    'Closed Classrooms',
	    'School Closure Status',
	);
}

sub csv {
    my $self = shift;
    my $csv = $self->SUPER::csv(@_);
    # drop the first column
    my @rows = split "\n",$csv;
    for my $row (@rows) {
	$row =~ s/,//;
	$row =~ s/^School,/School/;
    }
    return join "\n",@rows;
}

1;
