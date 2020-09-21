package CovidSchools::SchoolScraperPuppeteer;

use 5.006;
use strict;
use warnings;
use File::Temp 'tempfile';
use FindBin '$Bin';

use base 'CovidSchools::SchoolScraper';

use Carp 'croak';

=head1 NAME

CovidSchools::SchoolScraperPuppeteer - Subclass of SchoolScraper with support for Puppeteer retrieval

This is a version of CovidSchools::SchoolScraper which uses Puppeteer
for fetching web pages that generate content dynamically using
Javascript.

=cut

sub scrape {
    my $self = shift;
    my $url  = $self->url;

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

    $self->parse($html);
    return 1;
}

1;
