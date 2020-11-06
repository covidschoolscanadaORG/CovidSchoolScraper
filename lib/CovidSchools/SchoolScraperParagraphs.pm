package CovidSchools::SchoolScraperParagraphs;


use 5.006;
use strict;
use warnings;
use File::Temp 'tempfile';
use FindBin '$Bin';
use Text::CSV;
use Encode 'decode';
use base 'CovidSchools::SchoolScraper';
use HTML::Parser;
use Carp 'croak';

#completely override scrape method to read paragraphs
sub parse {
    my $self = shift;
    my $content = shift;

    $self->{raw_content} = decode('UTF-8',$content);
    my $parser = HTML::Parser->new(
	api_version => 3,
	text_h      => [ sub { $self->parse_text(shift); },'dtext' ]
	);

    $parser->parse($self->{raw_content});

    $self->{parsed_headers} = $self->headers;
    $self->{table}          = $self->table;
}

sub headers      { croak "implement headers() method in subclass" }
sub table        { croak "implement tables() method in subclass" }
sub parse_text   { croak "implement parse_text() method in subclass" }

1;

