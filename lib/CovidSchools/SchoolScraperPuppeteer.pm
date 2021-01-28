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
  try {
    await page.goto('$url');
  }
  catch(err) {
    console.error("Timed out fetching $url");
    process.exit(-1);
  }
  await page.waitForTimeout(500);  
  await delay(4000);
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

    $self->timestamp(DateTime->now(time_zone=>'local')->set_time_zone('floating'));
    $self->parse($html);
    return 1;
}

1;
