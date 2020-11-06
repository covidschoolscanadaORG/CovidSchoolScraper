package CovidSchools::SchoolScraper::saskatchewanPHU;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'Saskatchewan',
	DISTRICT => 'Saskatchewan PHU',
	URL      => 'https://www.saskatchewan.ca/government/health-care-administration-and-provider-resources/treatment-procedures-and-guidelines/emerging-public-health-issues/2019-novel-coronavirus/latest-updates/covid-19-active-outbreaks',
	);
}

sub table_fields {
    return (
	'Location',
	'Name',
	'Date Declared',
	'Information',
	);   
}

# filter out non-schools
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
	next unless $data[-1] =~ /School/;
	$csv     .= join(",",@data)."\n";
    }
    return $self->header.$csv;
}

1;
