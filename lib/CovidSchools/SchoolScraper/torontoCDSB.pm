package CovidSchools::SchoolScraper::torontoCDSB;

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Toronto CDSB',
	#	URL      => 'https://www.tcdsb.org/FORSTUDENTS/back-to-school/Pages/confirmed-covid-cases.aspx'
	URL      => 'https://docs.google.com/spreadsheets/d/e/2PACX-1vT1K1nGriULUzd73QeJG_wHwZ6fqV8Dra8z7V_a3RTzxvdazQvO4kpancuzAXuHDu35G7ozmKQsxMiN/pubhtml?rm=minimal&chrome=false&headers=false&gid=0'
	);
}

sub create_extractor {
    my $self = shift;
    HTML::TableExtract->new(
	count => 0,
	depth => 0,
	keep_headers => 0,
	slice_columns => 0,
	debug        => 0,
	decode       => 0,
	);
}

sub table_fields {
    return (
	'School Name',
	'Confirmed Student Cases','Confirmed Staff Cases',
	'Resolved Student Cases','Resolved Staff Cases',
	'School Status','Comment',
	);
}

# total hack
sub _create_school_data_structure {
    my $self = shift;
    my $te   = shift;
    my @rows = $te->rows;

    # we get an 8 element array for each row
    my $data_started = 0;
    my @table;

    $self->{parsed_headers} = [$self->table_fields];
    
    foreach my $r (@rows) {
	$data_started++ if $r->[3] && $r->[3] =~ /School Name/;
	$data_started++ if $r->[4] && $r->[4] =~ /Student/;
	next unless $data_started >= 2;

	last if defined $r->[3] && $r->[3] =~ /Total/;
	
	my (undef,undef,undef,$school,@fields) = @$r;
	next unless $school;
	push @table,[$school,@fields];
    }
    $self->{table} = \@table;
}

1;
