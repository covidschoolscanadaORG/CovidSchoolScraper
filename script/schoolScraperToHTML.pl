#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";

use CovidSchools::SchoolScraper;
use DateTime;
use File::Basename 'basename','dirname';
use File::Path 'make_path';
use IO::Dir;
use Text::CSV 'csv';
use Text::Diff;
use Encode qw(decode encode);

use feature 'unicode_strings';
binmode STDOUT,":encoding(UTF-8)";
# use open OUT=> ':encoding(UTF-8)';
use open IN => ':encoding(UTF-8)';
use utf8;

my $DATADIR = shift or die "Usage: schoolScraperToHTML.pl <destination directory>";
my $DATE    = DateTime->now(time_zone=>'local')->set_time_zone('floating');

my @dsbs = map {
    eval "use $_; 1" or die $@;
    $_->new();
} sort CovidSchools::SchoolScraper->board_subclasses;

# calculate what has changed
my $changed = what_has_changed(\@dsbs);

print <<END;
<!DOCTYPE html>
<html>
<head>
<title>COVID-19 School Advisories $DATE</title>
<style>
body {background-color: seashell; }
html {font-family: "Arial" !important; }
table, th, td {
    border: 1px solid gray;
    border-collapse: collapse;
}
tr.header {
    background-color: black;
    color: white;
}
tr.odd {
    background-color: wheat;
}
tr.even {
    background-color: powderblue;
}
tr.strikethrough {
    background-color: wheat;
    text-decoration: line-through;
}
tr.alert {
    background-color: red;
}
</style>
<meta charset="UTF-8">
</head>
<body> 
<div>
<h1>Contents</h1>
END
    ;

print "<ul>\n";

# create the list of links to changed data
if (%$changed) {
    print "<li><i><a href='#changed'>Schools with Changed Advisories:</a></i></li>\n";
    print "<ol>\n";
    for my $district (sort keys %$changed) {
	(my $d = $district) =~ s/\s+/_/g;
	$d = decode('UTF-8',$d);    
	my $tag   .= "${d}_changed";
	print "<li><a href=\"#$tag\">$district</a></li>\n";
    }
    print "</ol>\n";
} else {
    print "<li>(No advisories have changed over past 24 hours)</li>\n";
}

# create the list of links to current data
print "<li><i><a href='#all'>Current Advisories</a></i></li>\n";
print "<ol>\n";
foreach (@dsbs) {
    my $district = $_->district;
    $district    = decode('UTF-8',$district);
    (my $tag      = $district) =~ s/\s+/_/g;
    print "<li><a href='#$tag'>$district</a></li>\n";
}
print "</ol>\n";
print "</ul>\n";

################
# changed advisories
################
my $csv   = Text::CSV->new({binary=>1,
			    allow_loose_quotes=>1,
			    allow_loose_escapes=>1,
			    allow_unquoted_escape=>1,
			    allow_whitespace=>1,
			   });

if (%$changed) {
    print "<hr><h1><a id='changed'>Schools with Recently Changed Advisories</a></h1>\n";
    for my $dsb (@dsbs) {
	my $title = $dsb->district;
	my $source = $dsb->url;
	next unless $changed->{$title};
	(my $tag = $title) =~ s/\s+/_/g;
	$tag    .= "_changed";
	
	my $comparison = shift @{$changed->{$title}};
	my $headers    = shift @{$changed->{$title}};
	
	my @fields = csv_parse($csv,$headers);
	
	print "<h2><a id=\"$tag\" href=\"$source\">$title</a> ($comparison)</h2>\n";
	
	print "<table><tr class='header'>\n";
	print map {s/[\x00-\x1F]//g;"<th>$_</th>"} @fields;
	print "</tr>\n";
	my $style;
	foreach (@{$changed->{$title}}) {
	    @fields = csv_parse($csv,$_);
	    if ($fields[0] =~ s/^-//) {
		$style='strikethrough';
	    } elsif ($fields[0] =~ s/^\+//) {
		$style='alert';
	    }
	    print "<tr class='$style'>";
	    print map {s/[\x00-\x1F]//g;"<td>$_</td>"} @fields;
	    print "</tr>\n";
	}
	print "</table>\n";
    }
}

################
# all advisories
################
print "<h1><a id='all'>All Advisories</a></h1>\n";
for my $district (@dsbs) {
    my $path = dsb_to_dir($district);
    my @csv_files = find_csv($path);
    csv_2_html($csv_files[0]);
}
##############

print "<hr><a href='https://masks4canada.org'>Masks for Canada</a>\n";
print "</body></html>\n";
exit 0;

sub csv_parse {
    my ($csv,$string) = @_;
    return $csv->fields() if $csv->parse();
    return split /,/,$string;
}

sub dsb_to_dir {
    my $district = shift;
    (my $dir = $district->district) =~ s/\s+/_/g;
    return "$DATADIR/$dir";
}

sub csv_2_html {
    my $file = shift;
    my $aoa  = csv(in=>$file,
		   encoding=>'UTF-8',
	);

    my ($title,$source,$date,$ready_for_data,$header,$count);
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
	    $title = decode('UTF-8',$title);
	    my $tag = title2tag($title);
	    print "<h2><a id=\"$tag\" href=\"$source\">$title</a> ($date)</h2>\n";
	    $ready_for_data++;
	}

	my @fields = @$row;
	unless ($header++) {
	    print "<table><tr class='header'>\n";
	    print map {"<th>$_</th>"} @fields;
	    print "</tr>\n";
	    next;
	}
	my $odd = $count++ %2;
	my $class = $odd ? 'odd' : 'even';
	    
	print "<tr class='$class'>\n";
	print map {s/\s+$//; "<td>$_</td>"} @fields;
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
	my ($current,$previous,$test1,$test2) = find_csv(dsb_to_dir($dsb));
	#	my @diffs = calculate_diff($previous,$current);
	my @diffs = calculate_diff($test1||$previous,$current);
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
	unshift @changes,"$prev vs. $cur";
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
    my $d   = IO::Dir->new($dir);

    my %mtime;
    while (defined($_ = $d->read)) {
	next unless /\.csv$/;
	my $time  = (stat("$dir/$_"))[9];
	$mtime{"$dir/$_"} = $time;
    }

    return sort {$mtime{$b} <=> $mtime{$a}}  keys %mtime;
}

__END__