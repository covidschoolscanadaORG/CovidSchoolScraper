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

    $self->{raw_content} = $content;
    my $array_of_array   = Text::CSV::csv(in=>\$content);

    my @table;
    for my $row (@$array_of_array) {
	unless ($self->{parsed_headers}) { # first row
	    $self->{parsed_headers} = $row;
	    next;
	}
	push @table,$row;
    }
    $self->{table} = \@table;
}

# this does nothing but add the timestamp to the CSV table downloaded from Google
sub csv {
    my $self = shift;
    
    my $csv = '';
    $csv   .= $self->header;
    my $table = $self->{raw_content};
    $table    =~ s/,\s*$//gm;  # remove pesky trailing commas
    $table    =~ s/\r//g;      # remove pesky trailing newlines
    $csv .= $table;
    $csv;
}

1;
