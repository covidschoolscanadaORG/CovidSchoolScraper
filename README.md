CovidSchools-SchoolScraper

This is a Perl library and series of scripts that support the
Masks4Canada (https://masks4canada.org/) effort to provide transparent
and timely reports of Canadian school cases and closures during the
COVID-19 pandemic.

INSTALLATION

This module has several prerequisites to install prior to usage. Assuming
you are using an Ubuntu style system with "apt", run the following:

    apt install libhtml-tableextractor-perl libwww-perl \
    		liblwp-protocol-https-perl libdatetime-perl

Then, to install this module, run the following commands:

	perl Makefile.PL
	make
	make test
	# make install   - Not recommended; run from the Git directory

RUNNING THE SCRIPTS

To fetch CSV for a single school, run the scrapeSchool script. Prior
to installation, it will be located in the "script"
subdirectory. After installation, it will be in /usr/local/bin or
similar, but this is not recommended!

  % script/scrapeSchool.pl <school board parser>

To get the list of defined school board parsers, run the script
without any arguments. To get the CSV, run with the name of a parser.

Example output:

	% script/scrapeSchool.pl yorkRegionalDSB
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

     % mkdir ./scraped_data
     % script/scrapeSchools.pl ./scraped_data
     % ls -lR ./scraped_data
     ./scraped_data/:
     total 32
     drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Durham DSB'
     drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Durham-Peel Catholic DSB'
     drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Halton Catholic DSB'
     drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Halton District School Board'
     drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Renfrew County DSB'
     drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Toronto DSB'
     drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'Waterloo Regional DSB'
     drwxrwxr-x 2 lstein lstein 4096 Sep 20 17:20 'York Regional DSB'

     './scraped_data/Durham DSB':
     total 24
     -rw-rw-r-- 1 lstein lstein 4991 Sep 20 17:20 2020-09-20T17:20:13.csv
     -rw-rw-r-- 1 lstein lstein 4991 Sep 20 17:20 2020-09-20T17:20:20.csv
     -rw-rw-r-- 1 lstein lstein    0 Sep 20 17:20 2020-09-20T17:20:20.diff
     -rw-rw-r-- 1 lstein lstein 4991 Sep 20 17:20 2020-09-20T17:20:24.csv
     -rw-rw-r-- 1 lstein lstein    0 Sep 20 17:20 2020-09-20T17:20:24.diff

     './scraped_data/Durham-Peel Catholic DSB':
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

NODEJS AND PUPPETEER

At least one of the GTA school districts (Peel DSB) generates its advisory pages
dynamically with Javascript, and a regular ol' HTML parser won't cut it. For these
modules to work, you must install Puppeteer, a headless version of Google Chrome that
can be used to fetch and process the Javascript and turn it into parseable HTML. In the
base of the Git directory for this project, fun the following commands:

    sudo apt-get update
    sudo apt install nodejs npm    # lots of packages will be installed!!!!
    mkdir puppeteer
    chdir puppeteer
    npm i puppeteer

As long as you run the scrape scripts from within the script directory
of the Git project, the scraper modules that depend on Puppeteer will
work.

CRON SCRIPT

The script directory includes a script named nighly-cron.pl that
downloads newest data from each defined school district and then
mirrors the cumulative data to a designated Google Drive. The
mirroring part requires installation of the rclone package
(https://rclone.org/). There are several steps needed to connect
rclone to the correct Google Drive. Please see the documentation at
https://rclone.org/drive/ for a good step-by-step guide.

SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc CovidSchools::SchoolScraper

LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by Lincoln Stein.

This is free software, licensed under:

  GNU General General Public License v3

