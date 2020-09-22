package CovidSchools::SchoolScraper;

use 5.006;
use strict;
use warnings;

use LWP;
use HTML::TableExtract;
use File::Basename 'dirname','basename';
use DateTime;
use Carp 'croak';

# unsuccessful attempt to get rid of weird HTML characters
# use utf8;
# use Encode;
# use URI::Escape;

=head1 NAME

CovidSchools::SchoolScraper - Scrape COVID case numbers from school board web sites

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Scrape COVID case numbers from school board web sites

    use CovidSchools::SchoolScraper;
    my $ss  = CovidSchools::SchoolScraper::subclass->new();
    $ss->scrape() or die "Couldn't scrape ",$ss->error_str;
    my @schools = $ss->schools();
    my @table_fields = $ss->table_fields();
    for my $sch (@schools) {
       print $school,"\n";
       for my $field (@table_fields) {
           print "\t",$ss->school($sch){$field},"\n";
       }
    }

    # may or may not be appropriate...
    $html = $ss->raw_content;
    $csv  = $ss->csv;

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 CovidSchools::SchoolScraper->new()

=cut

BEGIN {
    $ENV{HTTPS_CA_DIR} = '/etc/ssl/certs';
}

sub new {
    my $class = shift;
    my %args  = @_;

    $args{DISTRICT} && $args{URL} or die "required arguments: DISTRICT, URL";
    return bless {
	district=>$args{DISTRICT},
	url     =>$args{URL},
    },$class
}

=head2 $ss->column_headers(@array)

Set the column headers to look for as an array. Must correspond to table headers used for {school, confirmed cases, closed classrooms, closed school}

Used without arguments returns ref to the array of headers. Headers may be regular expressions

=cut

sub column_headers {
    my $self   = shift;
    my @fields = @_;
    if (@fields) {
	$self->{column_headers} = \@fields;
    } else {
	$self->{column_headers} ||= [$self->table_fields];
	return $self->{column_headers};
    }
}

=head2 $array_ref = $ss->table_fields

Return a list of HTML table headers, e.g.
  

  sub table_fields { 
      return ('School','Confirmed Cases','Closed Classroom', 'Closed School')
  }

You can use regular expressions in the field names, as described in HTML::TableExtract.

This is intended to be subclassed for each school district.

=cut

sub table_fields {
    my $self = shift;
    croak "Please subclass ",ref($self)," and add a table_fields() method";
}

=head2 $ss->district

=cut

sub district {
    shift->{district}
}

=head2 $ss->url

=cut

sub url {shift->{url} }

=head2 $ss->scrape()

Run the scrape. Return true if successful. Otherwise set error().

=cut

sub scrape {
    my $self = shift;

    #pretend not to be a robot, because some schoolboards are blocking
    my $ua   = $self->new_user_agent();
    
    my $res  = $ua->get($self->url);
    unless ($res->is_success) {
	$self->error("mirroring of ".$self->district." failed: ".$res->message);
	return;
    }

    #    $self->parse(decode('utf8',uri_unescape($res->content)));
    $self->parse($res->content);
    return 1;
}

sub parse {
    my $self = shift;
    my $html_data = shift;
    
    $self->{raw_content} = $html_data;
    my $te = HTML::TableExtract->new(headers      => $self->column_headers,
				     keep_headers => 1,
	);

    $te->parse($html_data);
    unless ($te && $te->tables) {
	$self->error("Couldn't find parseable table in the HTML data");
	return;
    }

    $self->_create_school_data_structure($te);
    return 1;
}

=head2 @schools = $ss->schools

Return array of school names in district

=cut

sub schools {
    my $self = shift;
    $self->{schools} or return;
    return sort keys %{$self->{schools}};
}

=head2 $school_hash = $ss->school($school_name);

Returns a hashref corresponding to the named school. Keys are the table fields
defined by table_fields() method.

=cut

sub school {
    my $self = shift;
    my $school_name = shift;
    $self->{schools} or return;
    return $self->{schools}{$school_name};
}

=head2 $headers = $ss->parsed_headers

After parsing the table, the literal row headers will be returned by
this method as an array ref. These are used for generating the CSV

=cut

sub parsed_headers {
    return shift->{parsed_headers};
}

=head2 $content = $ss->raw_content

After parsing, returns the unparsed HTML content.

=cut

sub raw_content {
    my $self = shift;
    return $self->{raw_content};
}

=head2 $csv = $ss->csv;

Returns a comma-separated-values version of the school closure table.

=cut

sub csv {
    my $self = shift;

    my ($school,@fields) = $self->table_fields;
    my $literal_headers  = $self->parsed_headers() || [$school,@fields];
    
    my $csv = '';
    $csv   .= $self->header;
    $csv   .= join (',',@$literal_headers)."\n";
    for my $sch ($self->schools) {
	$csv .= join(',',
		     $sch,
		     @{$self->school($sch)}{@fields},
		     ). "\n";
    }
    return $csv;
}

=head2 $header = $ss->header;

Returns the file header string which identifies the time, date and source of the scrape

=cut

sub header {
    my $self = shift;
    my $date = DateTime->now(time_zone=>'local')->set_time_zone('floating');
    my $url  = $self->url;
    my $d   = '';
    $d     .= "# district: ".$self->district."\n";
    $d     .= "# source: $url\n";
    $d     .= "# date: $date\n";
   return $d;
}

=head2 $error = $ss->error('new error')

Set or return error string.

=cut

sub error {
    my $self = shift;
    $self->{error} = shift if @_;
    return $self->{error};
}

sub _get_field {
    my $self = shift;
    my ($field_name,$school) = @_;
    return unless $self->{schools};
    return $self->{schools}{$school}{$field_name};
}


sub _create_school_data_structure {
    my $self = shift;
    my $te   = shift;

    my @fields = @{$self->column_headers};
    shift @fields;  # get rid of the first column - school
    my %schools;
    for my $row ($te->rows) {

	# remove extraneous leading & trailing chars (don't know what causes this)
	foreach (@$row) {
	    next unless defined $_;
	    s/[\r\n]+/ /g;  # no newlines please!
	    s/[^a-zA-Z0-9()]+$//;
	    s/^[^a-zA-Z0-9()]+//;
	}

	unless ($self->{parsed_headers}) { # first row
	    $self->{parsed_headers} = $row;
	    next;
	}
	    
	my ($school,@data) = @$row;
	next unless $school;
	@{$schools{$school}}{@fields} = @data;

    }
    $self->{schools} = \%schools;
}

=head2 $ua = $self->new_user_agent()

Return a new LWP::UserAgent. This can be subclassed in order to
customize the user agent string, etc.

=cut

sub new_user_agent {
    return LWP::UserAgent->new(
	agent=>'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0')
}


=head2 @classes = CovidSchools::SchoolScraper->board_subclasses()

Returns a list of all the district school boards that have scraper subclasses defined.

=cut


sub board_subclasses {
    my $dir      = dirname(__FILE__);

    my @pm_files = <$dir/SchoolScraper/*.pm>;

    my @subclasses;
    foreach (@pm_files) {
	my $base =  basename($_);
	$base    =~ s/\.pm$//;
	push @subclasses,__PACKAGE__."::$base";
    }
    return @subclasses;
}

=head1 AUTHOR

Lincoln Stein, C<< <lincoln.stein at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-covidschools-schoolscraper at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=CovidSchools-SchoolScraper>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CovidSchools::SchoolScraper


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=CovidSchools-SchoolScraper>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CovidSchools-SchoolScraper>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/CovidSchools-SchoolScraper>

=item * Search CPAN

L<https://metacpan.org/release/CovidSchools-SchoolScraper>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by Lincoln Stein.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of CovidSchools::SchoolScraper
