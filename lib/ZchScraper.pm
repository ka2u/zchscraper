package ZchScraper;

use strict;
use warnings;
use Web::Scraper;
use URI;
use Data::Dumper;
use Encode;
use Perl6::Say;
use LWP::UserAgent;
use HTTP::Request;
use IO::File;
use YAML;


sub new {
    my ($class, $words, $ignore) = @_;
    bless {
        words => $words,
        ignore => $ignore,
        record => "./record/record",
    }, $class;
}

sub run {
    my ($self, @urls) =@_;

    my @results;
    foreach my $url (@urls) {
        my $res = $self->_scrape($url);
        push @results, $self->_parse($res);
    }
    $self->_record($self->{rec});

    return @results;
}

sub _scrape {
    my ($self, $url) = @_;

    my $scraper = scraper {
        process "#trad>a",
            'thread[]' => {
                title => 'TEXT',
                'url' => '@href',
            }
    };
    my $res = $scraper->scrape(
        URI->new($url)
    );
}

sub _parse {
    my ($self, $res) = @_;

    my @lines;
    my $before = YAML::LoadFile($self->{record});
    foreach my $line (@{$res->{thread}}) {
        $line->{title} = encode('utf8', $line->{title});
        if ($line->{title} =~ /$self->{words}/) {
            if ($line->{title} !~ /$self->{ignore}/) {
                $line->{title} =~ /^\d+: (.*)\((\d+)\)$/;
                $self->{rec}->{$1} = $2;
                if ($before->{$1} < $2) {
                    $line->{is_update} = 1;
                }
                $line->{url} = $self->_url($line->{url});
                push @lines, $line;
            }
        }
    }

    return @lines;
}

sub _record {
    my ($self, $rec) = @_;

    YAML::DumpFile $self->{record}, $rec;
}


sub _url {
    my ($self, $url) = @_;
    my @paths = split /\//, $url;

    return join "/", ($paths[0], $paths[1], $paths[2],
        "test", "read.cgi", $paths[3], $paths[4], $paths[5]);
}

1;
