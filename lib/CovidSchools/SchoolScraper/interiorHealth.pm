package CovidSchools::SchoolScraper::interiorHealth;

use 5.006;
use strict;
use warnings;
use Text::CSV;

use base 'CovidSchools::SchoolScraper';


sub new {
    my $class = shift;
    return $class->SUPER::new(
	PROVINCE => 'BC',
	DISTRICT => 'Interior Health',
	URL      => 'https://news.interiorhealth.ca/news/school-exposures/',
	);
}

sub table_fields {
    return ('City',
	    'School',
	    'Event',
	);
}

# unbelievable. Site gives a "406 Not Acceptable" error message, but continues to send the content!!!!
sub scrape {
    my $self = shift;

    #pretend not to be a robot, because some schoolboards are blocking
    my $ua   = $self->new_user_agent();
    
    my $res  = $ua->get($self->url);
    unless ($res->is_success || $res->code == 406) {
	$self->error("mirroring of ".$self->district." failed: ".$res->message." (".$res->code.")");
	return;
    }

    unless ($res->content) {
	$self->error("mirroring of ".$self->district." failed: empty content");
	return;
    }

    $self->timestamp(DateTime->now(time_zone=>'local')->set_time_zone('floating'));
    $self->parse($res->content);
}

sub csv {
    my $self = shift;
    my $headers = $self->parsed_headers;
    my $rows    = $self->{table};
    my $aoa     = [$headers,@$rows];
    my $csv = '';
    for my $row (@$aoa) {
	my @data  = map {  defined ? (/[,\s]/ ? "\"$_\"" : $_)
			       : '' } @$row;
	next unless length $data[0];
	foreach (@data) {$self->clean_text(\$_)};
	$csv     .= join(",",@data)."\n";
    }
    return $self->header.$csv;
}


1;
