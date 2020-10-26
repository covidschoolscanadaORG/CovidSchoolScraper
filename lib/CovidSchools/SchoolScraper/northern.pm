package CovidSchools::SchoolScraper::northern;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'Manitoba',
	DISTRICT => 'Northern',
	URL      => 'http://www.manitoba.ca/covid19/restartmb/prs/northern/index.html#north_schools',
	);
}

sub table_fields {
    return (
	'Town',
	'Location',
	'Dates/Times',
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
	unless ($data[0] =~ /town/i || $data[1] =~ /school|collegiate|child|elementary|elemental|middle|ècole/i) {
	    next;
	}
	$data[0]       ||= $previous_town;
	$previous_town   = $data[0];
	$csv     .= join(",",@data)."\n";
    }
    return $self->header.$csv;
}

1;
