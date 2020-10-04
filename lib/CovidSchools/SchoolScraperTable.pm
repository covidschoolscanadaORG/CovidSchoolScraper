package CovidSchools::SchoolScraperTable;

use 5.006;
use strict;
use warnings;
use File::Temp 'tempfile';
use FindBin '$Bin';
use Text::CSV;
use Encode 'decode';
use base 'CovidSchools::SchoolScraper';
use Carp 'croak';

# use this to directly download a CSV table

#completely override scrape method because it is a google doc in csv, not an HTML file
sub parse {
    my $self = shift;
    my $content = shift;

    $self->{raw_content} = decode('UTF-8',$content);
    my $array_of_array   = Text::CSV::csv(in=>\$content);

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
    
    my $csv = '';
    $csv   .= $self->header;
    my $table = $self->{raw_content};
    $table    =~ s/,\s*$//gm;  # remove pesky trailing commas
    $csv .= $table;
    $csv;
}

1;
