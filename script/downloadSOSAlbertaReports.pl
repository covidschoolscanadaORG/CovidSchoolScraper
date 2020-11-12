#!/usr/bin/perl

# one-off to download all of SOS Alberta's school reports.
# they are stored in a series of columns starting at column 10
# of the "School" table. We fetch each URL and store it in a
# directory named after the school.

use strict;
use LWP;
use HTML::TableExtract;
use File::Basename 'dirname','basename';
use Encode 'encode','decode';
use HTML::Entities ;

use constant SOS_URL => 'https://docs.google.com/spreadsheets/u/0/d/e/2PACX-1vQFuV2axZbkauJv8p09CnIPeBQuI_5A1CluMOZwvI1uwgN5x98MXjFEMkeFHjdRb55oMuW9TFhS5Inn/pubhtml/sheet?headers=false&gid=0';
use constant DESTINATION_DIR => '/home/lstein/Dropbox/Supporting docs/Alberta';

die "Destination directory '",DESTINATION_DIR,"' does not exist"
    unless -d DESTINATION_DIR;

chdir DESTINATION_DIR;

my $ua   = LWP::UserAgent->new(
    agent=>'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0',
    );
my $res  = $ua->get(SOS_URL);
die "Fetching of spreadsheet failed: ",$res->message unless $res->is_success;

my $extractor = HTML::TableExtract->new(headers       => ['School'],
					slice_columns => 0,
					keep_html     => 1,
					
    ) or die;

$extractor->parse($res->content) or die;
foreach my $row ($extractor->rows) {
    my @columns = @$row;
    my @reports = @columns[12..$#columns];
    next unless $reports[0];

    my @report_hrefs;
    foreach (@reports) {
	my ($href) = /url\?q=(.+?)\&amp;/;
	last unless $href;
	push @report_hrefs,HTML::Entities::decode($href);
    }

    my ($school) = $columns[2] =~ />([^<]+)<\/a>/;
    download_reports($school,@report_hrefs) if @report_hrefs;
}
    
exit 0;

sub download_reports {
    my ($school,@urls) = @_;
    $school = HTML::Entities::decode($school);
    $school =~ tr!/!_!;
    $school =~ s/^\s+//;
    $school =~ s/\s+$//;
    next unless $school;
    mkdir $school unless -e $school;
    -d $school or die "couldn't make school directory '$school'";

    for (my $i=0;$i<@urls;$i++) {

	# skip fetching if report already exists
	my $filename   = sprintf("%s/Report-%d",$school,$i+1);
	my @matches    = <"$filename.*">;
	next if @matches > 0;

	warn "found new report #",$i+1," for $school\n";

	my $res = $ua->get($urls[$i]);
	unless ($res->is_success) {
	    warn "Fetching of $school report # ",$i+1," failed for url ",$urls[$i],": ",$res->message;
	    next;
	}
	
	my $mime_type  = $res->header('Content-type');
	my ($extension)= $mime_type =~ m!/(\w+)!;
	$filename     .= ".$extension";

	open my $fh,'>',$filename or die "$filename: $!";
	print $fh $res->content;
	close $fh or die "$filename: $!";
    }
}

1;
