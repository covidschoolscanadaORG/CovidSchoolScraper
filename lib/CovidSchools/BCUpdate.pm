package CovidSchools::BCUpdate;
use strict;
use warnings;

use utf8;
use LWP::Simple 'get','mirror','is_success','RC_NOT_MODIFIED','RC_OK','RC_NOT_FOUND';
use HTML::TableExtract;
use File::Basename 'dirname','basename';
use File::Path 'make_path';
use File::Temp 'tempfile';
use File::stat;
use DateTime;
use Text::CSV 'csv';
use String::Approx 'amatch','adist';
use Encode 'encode','decode';
use FindBin '$Bin';
use Carp 'croak';

# default locations for stuff
use constant BASE          => "$ENV{HOME}/Dropbox/BC_Automation/School_Names_Reference/";
use constant SCHOOLS       => BASE . 'BC_official_names.csv';
use constant GOOGLE_NAMES  => BASE . 'BC_google_to_official_names.csv';
use constant TRACKER_NAMES => BASE . 'BC_covid_to_official_names.csv';
use constant CACHE_TIME    => 24 * 60 * 60;  # seconds to allow cache

# destination for the cleaned csv stuff
use constant CLEAN_CSV     => "$ENV{HOME}/Dropbox/BC_Automation/daily_update";

use constant RESULTS_PER_PAGE => 1000;  # for grassroots paging
use constant GRASSROOTS_TRACKER => 'https://bcschoolcovidtracker.knack.com/bc-school-covid-tracker#home/?view_3_per_page='.RESULTS_PER_PAGE;

# how much fuzz to add to approximate matching
use constant FUZZY_MATCH => '15%';

# how long to wait for tracker page to load (milliseconds)
use constant GRASSROOTS_TRACKER_DELAY=> 4000;   # for data to load, 4s per page
use constant GRASSROOTS_PAGE_DELAY   => 1000;   # request interval, 1s between pages

=head1 SYNOPSIS

BC School Automation for CovidSchoolsCanada

  use CovidSchools::BCUpdate;
  my $bc  = CovidSchools::BCUpdate->new(GRASSROOTS_TRACKER => 'URL of BC School Covid Tracker',
                                        SCHOOLS      => '<path to official school names and locations.csv>',
                                        GOOGLE_NAMES => '<path to join between Google Map names and official names.csv>',
                                        TRACKER_NAMES=> '<path to join between official school names and Covid school tracker.csv>',
                                        CACHE_DIR  => '/tmp/BCUpdate',
     );
  $bc->update('<path_to_clean.csv>');

=cut

sub new {
    my $class = shift;
    my %p     = @_;
    my $self = {
	grassroots_tracker => $p{GRASSROOTS_TRACKER} // GRASSROOTS_TRACKER,
	schools            => $p{SCHOOLS}            // SCHOOLS,
	google_names       => $p{GOOGLE_NAMES}       // GOOGLE_NAMES,
	tracker_names      => $p{TRACKER_NAMES}      // TRACKER_NAMES,
	cache_dir          => $p{CACHE_DIR},
	clean_csv_path     => $p{'CLEAN_CSV'} || CLEAN_CSV,
    };
    return bless $self=>$class;
}

=head2 ACCESSORS

grassroots_tracker(), schools(), google_names(), tracker_names()

=cut

sub clean_csv_path {
    my $self = shift;
    $self->{clean_csv_path} = shift if @_;
    $self->{clean_csv_path};
}

sub grassroots_tracker {
    my $self = shift;
    $self->{grassroots_tracker} = shift if @_;
    $self->{grassroots_tracker};
}

sub schools {
    my $self = shift;
    $self->{schools} = shift if @_;
    $self->{schools};
}

sub google_names {
    my $self = shift;
    $self->{google_names} = shift if @_;
    $self->{google_names};
}

sub tracker_names {
    my $self = shift;
    $self->{tracker_names} = shift if @_;
    $self->{tracker_names};
}

sub cache_dir {
    my $self = shift;
    $self->{cache_dir} = shift if @_;
    $self->{cache_dir};
}

=head1 METHODS

=head2 $bc->write_clean_file()

Write out appropriately-timestamped clean.csv file

=cut

sub write_clean_file {
    my $self = shift;
    my $table = shift;
    
    my $path = $self->clean_file_path;
    -d dirname($path) or make_path(dirname($path)) or die "Couldn't make directory for $path: $!";
    my ($data,$headers) = $self->make_clean_data($table);
    csv(in       => $data,
	out      => $path,
	sep_char => ',',
	encoding => 'utf-8',
	headers  => $headers
	);
}
=head2 $bc->write_tracker_file()

Write out appropriately-timestamped CSV file of the raw tracker data

=cut

sub write_tracker_file {
    my $self = shift;
    my $table = shift;
    
    my $path = $self->tracker_file_path;
    -d dirname($path) or make_path(dirname($path)) or die "Couldn't make directory for $path: $!";
    csv(in       => $table,
	out      => $path,
	sep_char => ',',
	encoding => 'utf-8',
	);
}

# create the data structure for the clean_data
# It will be an array-of-array in suitable format for CSV conversion
sub make_clean_data {
    my $self  = shift;
    my $tracker_table = shift;

    # headers for the clean file. School.Name is the *official* BC school name, which may not be unique
    my @headers = ('School.Code','School.Name','Tracker.Name','Google.Name',
		   'Total.cases.to.date','Total.students.to.date','Total.staff.to.date','Date','Article',
		   'Total.outbreaks.to.date','Outbreak.dates','Outbreak.Status',
		   'School.board','Type_of_school','City','Province',
		   'Latitude','Longitude');

    my $aa      = $tracker_table || $self->get_grassroots_tracker_table();

    # numbered fields of the tracker table:
    # 'Notification Date', 'School', 'Address', 'City', 'School District', 'Health Region', 'Notification', 'Exposure Dates', 'Extra Info', 'Documentation', 'Status'
    # 0                    1         2           3      4                   5                6               7                8             9                10
    my @tracker_headers = ('Notification Date', 'School', 'Address', 'City', 'School District', 'Health Region', 'Notification', 'Exposure Dates', 'Extra Info', 'Documentation', 'Status');
    
    # run through the tracker table, and aggregate cases per school
    my (%school,%code_to_tracker,%missing_schools);
    for my $row (@$aa) {
	my %f;
	@f{@tracker_headers} = @$row;

	my $code = $self->bc_schoolname_to_code($f{School},$f{City});
	unless ($code) {
	    $missing_schools{$f{School}}{$f{City}}++;
	    next;
	}
	$code_to_tracker{$code} = $f{School};
	
	my $date = $f{'Notification Date'};
	$date    =~ s!(\d+)/(\d+)/(\d+)!$3-$1-$2!;   # from mm/dd/yyyy to yyyy-mm-dd

	$school{$code}{$date}{Article} = $f{Documentation} || 'NA';
    }

    my $school_info     = $self->official_school_map();
    my $code_to_google  = $self->google_name_map();
	
    my @results;    # this will be the CSV file
    my @schools     = sort {$school_info->{$a}{'School.Name'} cmp $school_info->{$b}{'School.Name'}} keys %school;
    for my $code (@schools) {
	my $info = $school_info->{$code} or die "Logic error";

	my %r;
	$r{'School.Code'}  = $code;
	$r{'School.Name'}  = $info->{'School.Name'};
	$r{'Tracker.Name'} = $code_to_tracker{$code};
	$r{'Google.Name'}  = $code_to_google->{$code};

	my @events                    = keys %{$school{$code}}; # report dates
	$r{'Total.cases.to.date'}     = join ';',map {1} @events;  # creates a string like 1;1;1
	$r{'Total.students.to.date'}  = 'NA';
	$r{'Total.staff.to.date'}     = 'NA';
	$r{'Date'}                    = join ';',@events;
	$r{'Article'}                 = join ';',map {$school{$code}{$_}{Article}} @events;
	$r{'Total.outbreaks.to.date'} = 'NA';
	$r{'Outbreak.dates'}          = 'NA';
	$r{'Outbreak.status'}         = 'NA';
	$r{'School.board'}            = $info->{'District.Number'};
	$r{'Type_of_school'}          = 'NA';
	$r{'City'}                    = $info->{'City'};
	$r{'Province'}                = $info->{'Province'};
	$r{'Latitude'}                = $info->{'Latitude'};
	$r{'Longitude'}               = $info->{'Longitude'};

	push @results,[@r{@headers}];
    }

    print STDERR "The following schools are missing official BC school codes and were skipped (format <name> <city> (<events>)):\n";
    for my $school (sort keys %missing_schools) {
	for my $city (sort keys %{$missing_schools{$school}}) {
	    print STDERR "$school\t$city\t($missing_schools{$school}{$city})\n";
	}
    }

    return (\@results,\@headers);
}

sub clean_file_path {
    my $self = shift;
    my $datetime = DateTime->now(time_zone=>'local');
    my $ymd      = $datetime->ymd('');
    return join ('/',CLEAN_CSV,"export-$ymd","CanadaMap_BCMerge-$ymd.clean.csv");
}

sub tracker_file_path {
    my $self = shift;
    my $datetime = DateTime->now(time_zone=>'local');
    my $ymd      = $datetime->ymd('');
    return join ('/',CLEAN_CSV,"export-$ymd","BCTracker-raw-$ymd.csv");
}

=cut

=cut

=head2 $array_of_array = $bc->get_grassroots_tracker_data()

=cut

sub get_grassroots_html {
    my $self = shift;
    my $url  = shift;
    my $page = shift || 1;

    my $delay = GRASSROOTS_TRACKER_DELAY;
    
    my $node = `which node`;
    croak "node.js and puppeteer need to be installed for the ",ref($self)," scraper to work"
	unless $node;
    chomp($node);

    my $page_url = $url . "&view_3_page=$page";

    my $node_script =<<END;
const puppeteer = require('puppeteer');
const fs        = require('fs');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('$page_url');
  await page.waitForTimeout(500);  
  await delay($delay);
  const html = await page.content();
  console.log(html);
  await browser.close();
})();

function delay(time) {
   return new Promise(function(resolve) { 
       setTimeout(resolve, time)
   });
}
END
    ;
    my $puppeteer_dir = "$Bin/../puppeteer";
    my($infh,$filename) = tempfile();
    my $command = "| cd '$puppeteer_dir'; $node - >$filename";
    open my $outfh,$command or die "Could not open $command for input: $!";
    print $outfh $node_script;
    close $outfh;

    seek($infh,0,0);
    my $html = '';
    while (<$infh>) {
	$html .= $_;
    }
    
    return $html;
}

sub get_grassroots_tracker_html {
    my $self = shift;
    $self->load_cached_content($self->cache_dir) if $self->cache_dir();
	
    my $content = $self->cached_html_content();
    return $content if $content;
    
    my @rows;
    my $done = 0;
    my $page = 1;
    my @html_content;

    while (!$done) {
	sleep GRASSROOTS_PAGE_DELAY/1000 unless $page == 1;     # to avoid getting scrape errors
	my $content = $self->get_grassroots_html($self->grassroots_tracker,$page++);
	$content   || die "Couldn't extract content from grassroots tracker";
	push @html_content,$content;

	my ($last,$max) = $content =~ /Showing.+?\d+-(\d+).+?of.+?(\d+)/s;
	$done = $last >= $max;
    }

    $self->cached_html_content(\@html_content);
    $self->save_cached_content($self->cache_dir) if $self->cache_dir;
    return $self->cached_html_content;
}

sub get_grassroots_tracker_table {
    my $self = shift;
    my $pages = $self->cached_html_content || $self->get_grassroots_tracker_html;
    return unless $pages;

    my @rows;
    for my $content (@$pages) {

	my $extractor = HTML::TableExtract->new(headers => [$self->grassroots_headers()]);
	$extractor->parse($content);

	unless ($extractor) {
	    croak "Couldn't find parseable table in the HTML data";
	    return;
	}
	
	my @r = eval {$extractor->rows};
	unless (@r) { croak "Couldn't find parseable table in the HTML" }
    
	foreach (@r) {
	    foreach (@$_) {
		# get rid of newlines and excessive whitespace
		s/[\r\n]/ /g;
		s/\s{2,}/ /g;
		s/^\s+//g;
		s/\s+$//g;
		# get rid of nbsp character
		s/[\240]//g;
	    }
	}

	pop @r if $r[-1][0] eq ''; # last row seems to be empty
	push @rows,@r;
    }
    return \@rows;
}

# traverse the HTML and find the href for a link identified by content
sub get_url_for_link {
    my $self = shift;
    my $link = shift;
    my $pages = $self->get_grassroots_tracker_html;

    my $url;
    for my $page (@$pages) {
	($url) = $page =~ m!href="(.+)">\Q$link\E</a>! and last;
    }
    return $url;
}

sub mirror_articles {
    my $self  = shift;
    my ($table,$dest,$cache,$make_link_sub) = @_;
    $cache ||= {};
   
    my (%retrieval_status,$total);
    for my $row (@$table) {
	my $documentation = $row->[9]                                                     or next;
	my $mirror_dest   = $self->bc_schoolname_to_google_directory($row->[1],$row->[3]) or next;
	my $url           = $self->get_url_for_link($documentation)                       or next;

	my $path          = "/BC/$mirror_dest/".basename($url);
	my $response_code = $cache->{$path} ? RC_NOT_MODIFIED
	                                    : $self->mirror_article($url,"$dest/$mirror_dest");
	$total++;

	if ($response_code == 200) {
	    $retrieval_status{'new'}++;
	    print STDERR ".";
	} elsif ($response_code == RC_NOT_MODIFIED) {
	    $retrieval_status{'unchanged'}++;
	    print STDERR "=";
	} elsif ($response_code == RC_NOT_FOUND) {
	    $retrieval_status{'not found'}++;
	    print STDERR "!";
	} else {
	    $retrieval_status{'error'}++;
	    print STDERR "x";
	}

	next unless is_success($response_code) or $response_code == RC_NOT_MODIFIED;

	# if all goes well, we replace the row with the google link
	if ($make_link_sub && (my $new_url = $make_link_sub->($path))) {
	    $row->[9] = $new_url;
	} else {
	    $row->[9] = $path;
	}
    }
    print STDERR "\n";
    foreach ('new','unchanged','not found','error') { $retrieval_status{$_}+=0 }
    
    print STDERR <<END;
$total articles checked    
  New:           $retrieval_status{new}
  Unchanged:     $retrieval_status{unchanged}
  Missing (404): $retrieval_status{'not found'}
  Error:         $retrieval_status{error}
END
}

sub mirror_article {
    my $self     = shift;
    my ($url,$dest_dir)   = @_;
    my $filename = basename($url);
    return RC_NOT_MODIFIED if -e "$dest_dir/$filename";  # already got it

    my $node = `which node`;
    croak "node.js and puppeteer need to be installed for the ",ref($self)," scraper to work"
	unless $node;
    chomp($node);

    my $node_script =<<END;
const puppeteer = require('puppeteer');
const fs        = require('fs');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('$url');
  await page.waitForTimeout(500);  
  const html = await page.content();
  console.log(html);
  await browser.close();
})();
END
    ;
    my $puppeteer_dir = "$Bin/../puppeteer";
    my($infh,$infile) = tempfile('/tmp/BCUpdate-XXXXXX',UNLINK=>1);
    my $command = "| cd '$puppeteer_dir'; $node - >$infile";
    open my $outfh,$command or die "Could not open $command for input: $!";
    print $outfh $node_script;
    close $outfh;

    seek($infh,0,0);
    my $data = '';
    while ((my $bytes = read($infh,$data,8192,length($data)) > 0)) { 1 };

    # find the src tag
    my ($src) = $data =~ m!<img src="([^"]+)"!;
    return 400 unless $src;

    my $response = mirror($src,"$dest_dir/$filename");

    return $response;
}

################ cache control #############3
# returns array of HTML pages
sub cached_html_content {
    my $self = shift;
    $self->{cached_content} = shift if @_;
    return $self->{cached_content};
}

sub save_cached_content {
    my $self = shift;
    my $cache_dir = shift || '.';
    my $pages     = $self->cached_html_content or return;
    for (my $i=0;$i<@$pages;$i++) {
	open my $fh,'>',sprintf("$cache_dir/%02d.html",$i) or die $!;
	print $fh $pages->[$i];
	close $fh;
    }
}

# load cached content iff cached content is less than CACHE_TIME seconds old
# (currently 24h)
sub load_cached_content {
    my $self = shift;
    my $cache_dir = shift || '.';
    my @files     = sort <$cache_dir/*.html> or return;

    my $now    = time();
    my $oldest = $now;
    foreach (@files) {
	my $st    = stat($_);
	my $mtime = $st->mtime;
	$oldest   = $mtime if $oldest > $mtime;
    }
    return if $now-$oldest > CACHE_TIME;
    
    my @content;
    foreach (@files) {
	my $content = '';
	open my $fh,'<',$_ or die "$_: $!";
	while (<$fh>) { $content .= $_ }
	close $fh;
	push @content,$content;
    }
    $self->cached_html_content(\@content);
}

################ headers for the table to be extracted #############3
sub grassroots_headers {
    return ('Notification Date',
	    'School',
	    'Address',
	    'City',
	    'School District',
	    'Health Region',
	    'Notification',
	    'Exposure Dates',
	    'Extra Info',
	    'Documentation',
	    'Status');
}

######### canonicalize school names ########
sub bc_schoolname_to_code {
    my $self = shift;
    my $name = shift;
    my $city = shift;

    my @exact_matches = $self->official_school_name_to_codes($name);
    return $exact_matches[0] if @exact_matches == 1;

    # Otherwise we didn't find a single match, and use Shraddha's fuzzy match
    # file to resolve ambiguities
    my $bc_school_map = $self->bc_school_map;
    my @matches       = keys %{$bc_school_map->{$name}};
    return $matches[0] if @matches == 1;

    # Otherwise we try our own approximate matching
    my @approx_matches = $self->approximate_school_match($name,$city);
    return $approx_matches[0] if @approx_matches == 1;

    return;
}

sub bc_schoolname_to_google_directory {
    my $self   = shift;
    my $name   = shift;
    my $city   = shift;
    my $code   = $self->bc_schoolname_to_code($name,$city) or return;
    my $school = $self->official_school_map()->{$code}{'School.Name'};
    $school    =~ s!/! !g;  # no slashes allowed
    return "${code}_${school}";
}

    
# return hash of BC tracker school name to official school code
# format is:
#    $map->{$tracker_name}{$official_code} = $count
# so the code may be multivalued
sub bc_school_map {
    my $self = shift;
    return $self->{bc_school_map} ||= $self->get_bccovid_to_school_map();
}

sub get_bccovid_to_school_map {
    my $self = shift;
    my %map;

    # for future thought: use the csv headers=>'auto' parameter
    # to return an array-of-hashes
    my $aoa  = csv(in=>TRACKER_NAMES);

    # next line is the headers
    my @headers = @{shift @$aoa};
    
    # retrieve rest of content
    foreach (@$aoa) {
	my %fields;
	my @columns       = @$_;
	@fields{@headers} = @columns;

	next unless $fields{'School'};   # blank rows in file

	$map{$fields{'School'}}{$fields{'School.Code'}}++; # may not be unique
    }
    return \%map;
}

# official_school_map is a hash of school code to hash reference of fields
# e.g.
# map->{123456}{'Postal.Code'}
sub official_school_map {
    my $self = shift;
    return $self->{official_school_map} ||= get_official_school_map();
}

sub get_official_school_map {
    my $self = shift;
    my %map;
    my $aoh  = csv(in      => SCHOOLS,
		   headers => 'auto',
	);
    foreach (@$aoh) {
	my $code = $_->{'School.Code'};
	$map{$code} = $_;
    }
    return \%map;
}

# this will return a list of school codes matching names (e.g. "Aberdeen Elementary" has two matches)
sub official_school_name_to_codes {
    my $self = shift;
    my $name = shift;
    my $map  = $self->official_school_map;
    my @results;
    my @matches = grep {$map->{$_}{'School.Name'} eq $name} keys %$map;
    return @matches;
}

# This tries to perform an approximate match on BC tracker school names to
# official codes
sub approximate_school_match {
    my $self         = shift;
    my $tracker_name = shift;
    my $city         = shift;
    
    my $official_map = $self->official_school_map;
    my %approx_matches;

    # allow up to FUZZY_MATCH fuzz
    for my $code (keys %$official_map) {
	my $official_name = $official_map->{$code}{'School.Name'};
	my @m             = amatch($official_name,['i',FUZZY_MATCH],$tracker_name);
	$approx_matches{$code}++ if @m > 0;
    }

    # filter by distance and city
    my %results;
    for my $candidate (keys %approx_matches) {
	my $candidate_city = $official_map->{$candidate}{City} or die "school code $candidate: no city recorded";
	$results{$candidate}=adist($tracker_name,$official_map->{$candidate}{'School.Name'})
	    if !$city or (lc($city) eq lc($candidate_city));
    }

    return unless keys %results;  # no matches :-(
	
    # slightly bad - return best match
    my @sorted = sort {abs($results{$a}) <=> abs($results{$b})} keys %results;
    return $sorted[0];
}

# hash that maps a school code to its google name
# e.g.
# map->{123456} = 'Al-Hidaya School'
sub google_name_map {
    my $self = shift;
    return $self->{'google_name_map'} ||= $self->get_google_name_map();
}

sub get_google_name_map {
    my $self = shift;
    my $aoa  = csv(in=>GOOGLE_NAMES);

    # drop lines until we get to 'institute.name'
    my $row;
    while ($row = shift @$aoa) {
	last if $row->[0] eq 'institute.name';
    }

    my @headers = @$row;

    my %map;
    foreach (@$aoa) {
	my %fields;
	@fields{@headers} = @$_;
	$map{$fields{'School.Code'}} = $fields{'institute.name'};
    }

    return \%map;
}

1;
