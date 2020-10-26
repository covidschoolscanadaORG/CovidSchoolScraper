package CovidSchools::SchoolScraper::simcoeMuskokaHealth;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'ON',
	DISTRICT => 'Simcoe Muskoka Health',
	URL      => 'https://www.simcoemuskokahealth.org/JFY/HPPortal/ResourcesTools/OutbreakResources/CurrentOutbreaks',
	);
}

sub table_fields {
    return (
	'Date',
	'Institution',
	'Unit',
	'Setting',
	'Municipality',
	'Type',
	'COVID',
	'Over'
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
	unless ($data[1] =~ /institution/i || $data[1] =~ /school|collegiate|child|elementary|elemental|middle|ècole/i) {
	    next;
	}
	$csv     .= join(",",@data)."\n";
    }
    return $self->header.$csv;
}

1;
