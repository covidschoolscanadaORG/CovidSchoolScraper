#!/usr/bin/perl

# this script is used to generate template .pm files from
# the google spreadsheet of school boards and their advisory
# pages.

use strict;
use String::CamelCase 'camelize';
use File::Path 'make_path';

warn "generated .pm files will be found in ./pm-templates";
my $dest_dir = './pm-templates';
make_path($dest_dir);

while (<>) {
    chomp;
    my ($dsb,$webpage,$complicated) = split "\t";
    next unless $dsb;
    next if $dsb eq 'DSB';   # header
    my $class_name  = make_class_name($dsb);
    my $module_name = "$class_name.pm";
    open my $fh,">","$dest_dir/$module_name" or die "$dest_dir/$module_name: $!";
    print $fh <<END;
package CovidSchools\:\:SchoolScraper\:\:${class_name};

use 5.006;
use strict;
use warnings;
use base 'CovidSchools::SchoolScraper';

sub new {
    my \$class = shift;
    return \$class->SUPER::new(
	DISTRICT => '$dsb',
	URL      => '$webpage',
	);
}

sub table_fields {
    return ('School',
	    # FILL IN MISSING
	   );   
}
    1;
END
    ;
    close $fh or die $!;
}

exit 0;

sub make_class_name {
    my $class = shift;
    $class    = camelize($class);
    $class    =~ s/[^a-zA-Z0-9_]//g;
    $class    = lcfirst $class;
    return $class;
}

