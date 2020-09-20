package CovidSchools::SchoolScraper::durhamDSB;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraper';


sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Durham DSB',
	URL      => 'https://docs.google.com/spreadsheets/d/1YBn91VaM5IqGhJ_OvShCIpoohIRc2yFI0OwYzBaEe20/export?format=csv&gid=0',
	);
}

#completely override scrape method because it is a google doc in csv, not an HTML file
sub parse {
    my $self = shift;
    my $content = shift;

    $self->{raw_content} = $content;
    my $array_of_array = Text::CSV::csv(in=>\$content);

    my (%schools,@fields);
    for my $row (@$array_of_array) {
	unless ($self->{parsed_headers}) { # first row
	    $self->{parsed_headers} = $row;
	    @fields                 = @$row;
	    shift @fields;
	    next;
	}
	    
	my ($school,@data) = @$row;
	next unless $school;
	@{$schools{$school}}{@fields} = @data;

    }
    $self->{schools} = \%schools;
}

# this does nothing because there is no HTML table
sub csv {
    my $csv = shift->{raw_content};
    $csv    =~ s/,\s*$//gm;  # remove pesky trailing commas
    $csv;
}

1;
