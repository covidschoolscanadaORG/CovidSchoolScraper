package CovidSchools::SchoolScraper::torontoCDSB;

use 5.006;
use strict;
use warnings;
use Encode 'decode';
use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Toronto CDSB',
	#	URL      => 'https://www.tcdsb.org/FORSTUDENTS/back-to-school/Pages/confirmed-covid-cases.aspx'
	#	URL      => 'https://docs.google.com/spreadsheets/d/e/2PACX-1vT1K1nGriULUzd73QeJG_wHwZ6fqV8Dra8z7V_a3RTzxvdazQvO4kpancuzAXuHDu35G7ozmKQsxMiN/pubhtml?rm=minimal&chrome=false&headers=false&gid=0'
	URL => 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQdDk08AkrTZ5NsN8xa9-JhNazEtTRS57SGL4mE5Zp3sGe08fLbj_E7vTkuJCkEiB7TGhtnRyCxJmFV/pubhtml?rm=minimal&chrome=false&headers=false&gid=0'
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

#sub table_fields {
#    return (
#	'School Name',
#	'School Status',
#	'#',
#	'Confirmation',
#	'Student',
#	'Staff',
#	'Status',
#	);
#}


sub _create_school_data_structure {
     my $self = shift;
     my $te   = shift;

     # hard coded
     $self->{parsed_headers} = ['School Name',
				'School Status',
				'#',
				'Confirmation Date',
				'Student Cases',
				'Staff Cases',
				'Case Status',
	 ];

     my ($data_started,@table,@data,@row);
     my @rows = $te->rows;
     foreach my $r (@rows) {
	 my (undef,undef,@row) = @$r;
	 if ($row[0] && $row[0] eq 'School Name') { # data starting
	     $data_started++;
	     next;
	 }
	 next unless $data_started;
	 next unless $row[2] && $row[2] =~ /\d+/;
	 for (my $i=0;$i<@row;$i++) {
	     $data[$i] =  decode('UTF-8'=>$row[$i])
		 if defined $row[$i];
	     $self->clean_text(\{$data[$i]})
	 }
	 push @table,[@data];
     }
     $self->{table} = \@table;
}
1;
