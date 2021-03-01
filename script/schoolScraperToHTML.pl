#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";

use CovidSchools::SchoolScraper;
use DateTime;
use Date::Parse;
use File::Basename 'basename','dirname';
use File::Path 'make_path';
use IO::Dir;
use Text::CSV 'csv';
use Text::Diff;
use Encode qw(decode encode);

use feature 'unicode_strings';
use open ':std'=>':encoding(UTF-8)';
use utf8;

my $DATADIR = shift or die "Usage: schoolScraperToHTML.pl <destination directory>";

my $DATE     = DateTime->now(time_zone=>'local')->set_time_zone('floating');
my ($TODAY)  = $DATE =~ m!(\d+-\d+-\d+)T\d+:!;

my @dsbs = map {
    my $dsb = eval "use $_; 1" && eval {$_->new()};
    warn $@ unless $dsb;
    $dsb ? $dsb : ();
} sort CovidSchools::SchoolScraper->board_subclasses;

my %provinces;
foreach (@dsbs) {
    next unless $_;
    my $province = $_->province;
    $provinces{$province}{$_->district}=$_;
}

# calculate what has changed
my $changed = what_has_changed(\@dsbs);

my $localtime = localtime();

print <<END;
---
layout: page
Title: COVID-19 School Advisories $DATE
---

<html>
<head>
<title>COVID-19 School Advisories $DATE</title>
<style>
th,td { font-size: 14px; }
table {
    border: 1px solid;
    width: 100%;
}
tr.odd {
    background-color: wheat;
}
tr.even {
    background-color: powderblue;
}
.strikethrough {
    text-decoration: line-through;
}
.alert {
    background-color: darkorange;
</style>
<meta charset="UTF-8">
</head>
<body> 
<div>
<h1>Summary of School COVID-19 Alerts, updated $localtime</h1>
END
    ;

print "<ul>\n";

# create the list of links to changed data
if (%$changed) {
    print "<li><i><a href='#changed'>Schools with Changed Advisories:</a></i></li>\n";
    print "<ul>\n";
    for my $province (sort keys %provinces) {
	print "<li><b>$province</b></li>\n";
	print "<ol>\n";
	for my $district (sort keys %$changed) {
	    next unless $provinces{$province}{$district};
	    (my $d = $district) =~ s/\s+/_/g;
	    my $tag   .= "${d}_changed";
	    print "<li><a href=\"#$tag\">$district</a></li>\n";
	}
	print "</ol>\n";
    }
    print "</ul>\n";
} else {
    print "<li>(No advisories have changed over past 24 hours)</li>\n";
}

# create the list of links to current data
print "<li><i><a href='#all'>Current Advisories</a></i></li>\n";

print "<ul>\n";
for my $province (sort keys %provinces) {
    print "<li><b>$province</b></li>\n";
    print "<ol>\n";
    foreach (@dsbs) {
	my $district = $_->district;
	next unless $provinces{$province}{$district};
	my $tag      = title2tag($district);
	print "<li><a href=\"#$tag\">$district</a></li>\n";
    }
    print "</ol>\n";
}
print "</ul>\n";
print "</ul>\n";

################
# changed advisories
################
my $csv   = Text::CSV->new({binary=>1,
			    decode_utf8=>1,
			    allow_loose_quotes=>1,
#			    allow_loose_escapes=>1,
#			    allow_unquoted_escape=>1,
			    allow_whitespace=>1,
			    auto_diag=>1,
			    diag_verbose=>2
			   });

if (%$changed) {
    print <<END;
<hr><h2 id='changed'>Schools with Recently Changed Advisories</h2>
<div style="padding-left: 50px">
<p><span class="strikethrough">Previous day's numbers</span><br/>
<span class="alert">Current day's numbers</span></p>
</div>
END
	;

    for my $dsb (sort {$a->prov cmp $b->prov || $a->district cmp $b->district} @dsbs) {
	my $title  = $dsb->district;
	my $source = $dsb->url;
	my $prov = $dsb->prov;
	next unless $changed->{$title};
	
	my $comparison = shift @{$changed->{$title}};
	my $headers    = shift @{$changed->{$title}};
	
	my @headers = csv_parse($csv,$headers);

	(my $tag = $title) =~ s/\s+/_/g;
	$tag    .= "_changed";

	
	print "<a id=\"$tag\" href=\"$source\"><h3>[$prov] $title ($comparison)</h3></a>\n";
	
	print "<table><tr class='header'>\n";
	print map {s/[\x00-\x1F"]//g;"<th>$_</th>"} @headers;
	print "</tr>\n";
	my $style;
	foreach (@{$changed->{$title}}) {
	    my @fields = csv_parse($csv,$_);
	    if ($fields[0] =~ s/^-//) {
		$style='strikethrough';
	    } elsif ($fields[0] =~ s/^\+//) {
		$style='alert';
	    } else {
		$style='alert';
	    }
	    print "<tr class='$style'>";
	    print map {s/[\x00-\x1F"]//g;"<td class='$style'>$_</td>"} map {decode('UTF-8'=>$_)} @fields[0..$#headers]; # trim trailing fields without headers
	    print "</tr>\n";
	}
	print "</table>\n";
    }
}

################
# all advisories
################
print "<hr>\n";
print "<h2 id='all'>All Advisories</h2>\n";
for my $district (sort { $a->prov cmp $b->prov || $a->district cmp $b->district } @dsbs) {
    my $path      = dsb_to_dir($district);
    my @csv_files = find_csv($path) or next;
    csv_2_html($csv_files[0],$district);
}
##############

print "<hr><a href='https://masks4canada.org'>Masks for Canada</a>\n";
print "</body></html>\n";
exit 0;

sub csv_parse {
    my ($csv,$string) = @_;
    return $csv->fields() if $csv->parse($string);
    return split /,/,$string;
}

sub dsb_to_dir {
    my $district = shift;
    (my $dir = $district->district) =~ s/\s+/_/g;
    return "$DATADIR/$dir";
}

sub csv_2_html {
    my $file = shift;
    my $dsb  = shift;
    my $aoa  = csv(in       => $file,
		   encoding => 'utf-8',
		   allow_loose_quotes=>1,
		   diag_verbose=>1,
	);

    my ($title,$source,$date,$ready_for_data,$header,$count);
    my $prov = $dsb->prov;
    my @headers;
    
    for my $row (@$aoa) {

	if ($row->[0] =~ /^\# district: (.+)/) {
	    $title = $1;
	    next;
	}

	if ($row->[0] =~ /^\# source: (.+)/) {
	    $source = $1;
	    next;
	}

	if ($row->[0] =~ /^\# date: (.+)/) {
	    $date = $1;
	    next;
	}

	if (!$ready_for_data++ && $title && $source && $date) {
	    #	    my $t   = decode('UTF-8'=>$title);
	    my $t = $title;
	    my $tag = title2tag($t);
	    my $nice_date = nice_date($date);
	    print "<a id=\"$tag\" href=\"$source\"><h3>[$prov] $t ($nice_date)</h3></a>\n";
	    $ready_for_data++;
	}


	my @fields = @$row;
	foreach (@fields) {s/&nbsp;//}
	unless (@headers) {
	    @headers = @fields;
	    print "<table><tr class='header'>\n";
	    print map {"<th>$_</th>"} @headers;
	    print "</tr>\n";
	    next;
	}
	my $odd = $count++ %2;
	my $class = $odd ? 'odd' : 'even';
	    
	print "<tr class='$class'>\n";
	print map {s/\s+$//; "<td>$_</td>"} @fields[0..$#headers];
	print "</tr>\n";
    }
    print "</table>\n";
}

sub title2tag {
     my $title = shift;
     $title   =~ s/\s+/_/g;
     $title;
}

sub what_has_changed {
    my $dsbs = shift;
    my %changed;
    foreach my $dsb (@$dsbs) {
	my ($current,$previous) = find_csv(dsb_to_dir($dsb));
	next unless $current && $previous;

	my $name = $dsb->district.' (class '.ref($dsb).' )';
	    
	if ($current !~ m!/$TODAY!) {
	    warn "No current scrape for $name. Skipping";
	    next;
	}
	if (-z $current) {
	    warn "Today's scrape for $name is empty. Skipping";
	    next;
	}
	if (-z $previous) {
	    warn "Yesterday's scrape for $name is empty. Skipping";
	    next;
	}
	my @diffs = calculate_diff($previous,$current);
	$changed{$dsb->district} = \@diffs if @diffs;
    }
    return \%changed;
}

sub calculate_diff {
    my ($previous,$current) = @_;
    my $diff = diff($previous,$current);
    my @changes;

    my @lines = split "\n",$diff;
    foreach (@lines) {
	next if /^---/;
	next if /^\+\+\+/;

	if (/^[-+]/ && !/[-+]\#/) { # removed line, not metadata
	    push @changes,$_;
	}
    }
    if (@changes) {
	unshift @changes,get_row_headers($current);
	my $prev = basename($previous);
	my $cur  = basename($current);
	foreach ($prev,$cur) { s/\.csv$//; }
	unshift @changes,nice_date($cur) . ' vs '.nice_date($prev);
    }
    return @changes;
}

sub get_row_headers {
    my $file = shift;

    open my $fh,'<',$file or die "$file: $!";
    while (<$fh>) {
	chomp;
	next if /^#/;
	return $_;
    }
}

sub find_csv {
    my $dir = shift;
    my $d   = IO::Dir->new($dir) or return;

    my %name;
    while (defined($_ = $d->read)) {
	next unless /\.csv$/;
	$name{"$dir/$_"} = $_;
    }

    return sort {$name{$b} cmp $name{$a}}  keys %name;
}

sub nice_date {
    my $ts  = str2time(shift);
    my $nice_date = DateTime->from_epoch(epoch=>$ts)->set_time_zone('local')->strftime('%a %b %d, %Y');
    return $nice_date;
}

__END__
