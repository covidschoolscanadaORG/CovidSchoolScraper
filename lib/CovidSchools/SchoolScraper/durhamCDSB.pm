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
    return ['School','Address','Confirmed Unresolved Cases'];
}

sub table {
    my $self = shift;
    my @table;
    
    while ($self->{converted_text} =~ /^(.+)\n{2,}(.+)\n(\d+) Confirmed Case/mg) {
	my $school = $1;
	$school =~ s/\240//g; # nbsp character
	push @table,[$school,$2,$3];
    }
    return \@table;
}

1;

