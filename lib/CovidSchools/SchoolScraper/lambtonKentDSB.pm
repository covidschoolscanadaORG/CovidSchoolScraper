package CovidSchools::SchoolScraper::lambtonKentDSB;

use 5.006;
use strict;
use warnings;
use Text::CSV;
use Encode 'decode';

use base 'CovidSchools::SchoolScraper';

sub new {
    my $class = shift;
    return $class->SUPER::new(
	DISTRICT => 'Lambton Kent DSB',
	URL      => 'https://www.lkdsb.net/Board/Community/PublicHealth/COVID-19Advisory/Pages/default.aspx#/=',
	);
}


sub create_extractor {
    my $self = shift;
    HTML::TableExtract->new(#headers      => $self->column_headers,
			    keep_headers => 0,
			    debug        => 0,
			    decode       => 1,
	);
}

sub table_fields {
    return (
	'School',
	'Confirmed Cases',
	'School Status',
	);
}

sub csv {
    my $self = shift;
    my $rows    = $self->{table};

    # we're going to join the first set of tables to the second set
    my $row_cnt = @$rows;
    my @school_names = @$rows[0..$row_cnt/2-1];
    my @status       = @$rows[$row_cnt/2..$row_cnt-1];

    shift @status;  # first row is a copy of the headers
    
    my @fixed_table = [$self->table_fields];
    for (my $i=0;$i<@school_names;$i++) {
	push @fixed_table,[$school_names[$i][0],$status[$i][1],$status[$i][2]];
    }
    

    my $csv = '';
    for my $row (@fixed_table) {
	foreach (@$row) { $self->clean_text(\$_) }
	my @data  = map {  defined ? (/[,\s]/ ? "\"$_\"" : $_)
			       : '' } @$row;
	$csv     .= join(",",@data)."\n";
    }
    return $self->header.$csv;
}


sub clean_text {
    my $self = shift;
    my $t    = shift;
    $$t      =~ s/^\s+//g;
    $$t      =~ s/\s+$//g;
    $$t      =~ s/[^a-zA-Z0-9 .&_-]//g;
}

1;
