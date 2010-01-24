#!/usr/bin/perl

use strict;
use warnings;
use Template;
use CGI qw/:standard/;
use lib qw(./lib);
use ZchScraper;

my $words = "(hoge|fuga)";
my $ignore_words = "(foo|boo)"

my @urls = ("url1", "url2");

my $scraper = ZchScraper->new($words, $ignore_words);
my @results = $scraper->run(@urls);

my $template = Template->new(
    INCLUDE_PATH => './tmpl',
);

print header(-type => 'text/html', -charset => 'utf-8');
$template->process('index.tt', {results => \@results}) 
    || die $template->error;
