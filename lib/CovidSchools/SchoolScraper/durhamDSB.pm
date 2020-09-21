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

# this does nothing but add the timestamp to the CSV table downloaded from Google
sub csv {
    my $self = shift;
    
    my $date = DateTime->now(time_zone=>'local')->set_time_zone('floating');
    my $csv = '';
    $csv   .= "# ".$self->district." scraped at $date\n";

    my $table = $self->{raw_content};
    $table    =~ s/,\s*$//gm;  # remove pesky trailing commas
    $csv .= $table;
    $csv;
}

1;
