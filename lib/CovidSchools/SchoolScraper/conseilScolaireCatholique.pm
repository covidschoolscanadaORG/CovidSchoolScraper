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

sub table_fields {
    return (
	'Nom',
	'Région',
	'Nouveaux cas',
	'Cas',
	'Statut',
	'Date',
	)
}

sub csv {
    my $self = shift;
    my $headers = $self->parsed_headers;
    my $rows    = $self->{table};
    my $aoa     = [$headers,@$rows];
    my $csv = '';
    for my $row (@$aoa) {
	my @data  = map {  defined ? (/[,\s]/ ? "\"$_\"" : $_)
			       : '' } @$row;
	foreach (@data) {$self->clean_text(\$_)};
	unless ($data[0]) {
	    next;
	}
	$csv     .= join(",",@data)."\n";
    }
    return $self->header.$csv;
}



1;
