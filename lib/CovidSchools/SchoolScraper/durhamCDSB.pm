package CovidSchools::SchoolScraper::durhamCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraperParagraphs';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Durham Catholic DSB',
	URL      => 'https://www.dcdsb.ca/en/our-board/covid-19.aspx',
	);
}

sub parse_text {
    my $self = shift;
    my $text = shift;
    $self->{converted_text} .= $text;
}

sub headers {
    return ['School','Address','Confirmed Cases','Resolved Cases'];
}

sub table {
    my $self = shift;
    my @table;
    
    while ($self->{converted_text} =~ /^(.+)\n{2,}(.+)\n(\d+) Confirmed Cases?\n(?:(\d+) Resolved Case)?/mg) {
	my ($school,$address,$confirmed,$resolved) = ($1,$2,$3,$4);
	$school =~ s/\240//g; # nbsp character
	push @table,[$school,$address,$confirmed||0,$resolved||0];
    }
    return \@table;
}

1;

