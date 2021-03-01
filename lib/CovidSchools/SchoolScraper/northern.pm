package CovidSchools::SchoolScraper::northern;

use 5.006;
use strict;
use warnings;
use Carp 'croak';
use base 'CovidSchools::SchoolScraperPuppeteer';

# NOTE: HTML is not a standard table - needs special parsing

sub new {
    my $class = shift;
    croak "None of the Manitoba scrapers are working due to a recent change in table format.";
    return $class->SUPER::new(
	PROVINCE => 'Manitoba',
	DISTRICT => 'Northern',
	#	URL      => 'http://www.manitoba.ca/covid19/restartmb/prs/northern/index.html#north_schools',
	URL      => 'https://experience.arcgis.com/experience/611bde4f5cd644629f428f0ccf9c9498/page/page_1/',
	);
}

sub table_fields {
    return (
	'Location',
	'Total',
	'Staff',
	'Non-staff',
	'Active',
	'Recovered',
	'Deaths',
	);   
}

# filter out non-schools
sub csv {
    my $self = shift;
    my $headers = $self->parsed_headers;
    my $rows    = $self->{table};
    my $aoa     = [$headers,@$rows];
    my $csv = '';
    my $previous_town;
    for my $row (@$aoa) {
	my @data  = map {  defined ? (/[,\s]/ ? "\"$_\"" : $_)
			       : '' } @$row;
	foreach (@data) {$self->clean_text(\$_)};
	unless ($data[0] =~ /school|collegiate|child|elementary|elemental|middle|ècole/i) {
	    next;
	}
	$csv     .= join(",",@data)."\n";
    }
    return $self->header.$csv;
}

1;
