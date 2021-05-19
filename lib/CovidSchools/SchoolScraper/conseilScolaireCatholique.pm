package CovidSchools::SchoolScraper::conseilScolaireCatholique;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'Ontario',
	DISTRICT => 'Conseil Scolaire Catholique',
	URL      => 'https://docs.google.com/spreadsheets/u/0/d/e/2PACX-1vRfQtoOl51ip_g-uoy3Mujs4BDzdm00RkNObNP91hpBUX-c6dZ8oWmO-cE8rY8pcw/pubhtml/sheet?headers=false&gid=1013444647',
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
sub table_fields {
    return (
	'Bureau',
	'Nouveaux cas',
	'Statut',
	'Date',
	)
}

sub csv {
    my $self = shift;
    my $rows    = $self->{table};
    my $aoa     = $rows;
    my $csv = '';
    for my $row (@$aoa) {
	my @data  = map {  defined ? (/[,\s]/ ? "\"$_\"" : $_)
			       : '' } @$row;
	foreach (@data) {$self->clean_text(\$_)};
	unless ($data[2]) { # skip empty rows
	    next;
	}
	shift @data; # undesirable row counter in first cell
	$csv     .= join(",",@data)."\n";
    }
    return $csv;
}



1;
