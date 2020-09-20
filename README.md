CovidSchools-SchoolScraper

The README is used to introduce the module and provide instructions on
how to install the module, any machine dependencies it may have (for
example C compilers and installed libraries) and any other information
that should be provided before the module is installed.

A README file is required for CPAN modules since CPAN extracts the README
file from a module distribution so that people browsing the archive
can use it to get an idea of the module's uses. It is usually a good idea
to provide version information here so that people can decide whether
fixes for the module are worth downloading.

INSTALLATION

This module has several prerequisites to install prior to usage. Assuming
you are using an Ubuntu style system with "apt", run the following:

  apt install libhtml-tableextractor-perl libwww-perl \
              liblwp-protocol-https-perl libdatetime-perl

Then, to install this module, run the following commands:

	perl Makefile.PL
	make
	make test
	make install

RUNNING THE SCRIPTS

To fetch CSV for a single school, run the scrapeSchool script. Prior
to installation, it will be located in the "script"
subdirectory. After installation, it will be in /usr/local/bin or
similar.

  % scrapeSchool.pl <school board parser>

To get the list of defined school board parsers, run the script
without any arguments. To get the CSV, run with the name of a parser.

Example output:

  % scrapeSchool.pl yorkRegionalDSB
  # York Regional DSB scraped at 2020-09-20T17:16:50
  School Name,Coâânfirmed Cases,Closed Classrooms,Closure Status
  Adrienne Clarkson P.S,0,0,Open
  Aldergrove P.S,0,0,Open
  Alexander Mackenzie H.S,0,0,Open
  Alexander Muir P.S,0,0,Open
  Anne Frank P.S,0,0,Open
  ...

To generate a running record of timestamped school advisories, use the
scrapeSchools.pl script (note plural "schools"). It takes a single
argument which is the name of a directory to store the data in. Each
time you run it, it will create a new timestamped file and generate a
diff of the previous one.

   % script/scrapeSchools.pl /tmp/schools
   % ls -lR /tmp/schools
   /tmp/schools/:
   total 32
   drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Durham DSB'
   drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Durham-Peel Catholic DSB'
   drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Halton Catholic DSB'
   drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Halton District School Board'
   drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Renfrew County DSB'
   drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Toronto DSB'
   drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Waterloo Regional DSB'
   drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'York Regional DSB'

   '/tmp/schools/Durham DSB':
   total 24
   -rw-rw-r-- 1 lstein lstein 4991 Sep 20 17:20 2020-09-20T17:20:13.csv
   -rw-rw-r-- 1 lstein lstein 4991 Sep 20 17:20 2020-09-20T17:20:20.csv
   -rw-rw-r-- 1 lstein lstein    0 Sep 20 17:20 2020-09-20T17:20:20.diff
   -rw-rw-r-- 1 lstein lstein 4991 Sep 20 17:20 2020-09-20T17:20:24.csv
   -rw-rw-r-- 1 lstein lstein    0 Sep 20 17:20 2020-09-20T17:20:24.diff

   '/tmp/schools/Durham-Peel Catholic DSB':
   total 36
   -rw-rw-r-- 1 lstein lstein 5168 Sep 20 17:20 2020-09-20T17:20:14.csv
   -rw-rw-r-- 1 lstein lstein 5168 Sep 20 17:20 2020-09-20T17:20:21.csv
   -rw-rw-r-- 1 lstein lstein  628 Sep 20 17:20 2020-09-20T17:20:21.diff
   -rw-rw-r-- 1 lstein lstein 5168 Sep 20 17:20 2020-09-20T17:20:24.csv
   -rw-rw-r-- 1 lstein lstein 6382 Sep 20 17:20 2020-09-20T17:20:24.diff
   ...

ADDING NEW SCRAPERS

Scrapers are defined in .pm module files located in the directory
lib/CovidSchools/SchoolScraper/. They all inherit from a base class
named CovidSchools::SchoolScraper.

Copy an existing .pm file and modify to meet your needs. For a simple
advisory page that consists of a single HTML table, you will need to
define a new() method to define the district name and page URL, and
define a table_fields() method that returns a list of the header fields
from the table you wish to fetch.

A few special cases may help you along:

1. durhamPeelCatholicDSB.pm had trouble with its certificates, and overrides
   the new_user_agent() method to pass special SSL arguments to the URL fetcher.

2. durhamDSB.pm uses a Google doc instead of an HTML form. This example shows how
   to override the parse() method in order to deal with a new content type.

SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc CovidSchools::SchoolScraper

You can also look for information at:

    RT, CPAN's request tracker (report bugs here)
        https://rt.cpan.org/NoAuth/Bugs.html?Dist=CovidSchools-SchoolScraper

    AnnoCPAN, Annotated CPAN documentation
        http://annocpan.org/dist/CovidSchools-SchoolScraper

    CPAN Ratings
        https://cpanratings.perl.org/d/CovidSchools-SchoolScraper

    Search CPAN
        https://metacpan.org/release/CovidSchools-SchoolScraper


LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by Lincoln Stein.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

