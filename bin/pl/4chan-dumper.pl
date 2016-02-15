#!/usr/bin/env perl
########################################################################
# Copyright (C) 2012-2014 Wojciech Siewierski                          #
#                                                                      #
# This program is free software; you can redistribute it and/or        #
# modify it under the terms of the GNU General Public License          #
# as published by the Free Software Foundation; either version 3       #
# of the License, or (at your option) any later version.               #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program. If not, see <http://www.gnu.org/licenses/>. #
########################################################################

use warnings;
use strict;
use 5.010;

use JSON::XS;
use Encode qw(encode);

use WWW::Curl::Easy;

sub downloader {
    my $options = shift;
    my $curl = WWW::Curl::Easy->new(@_);

    if ($options) {
        for my $key (keys %$options) {
            $curl->setopt($key, $options->{$key})
        }
    }

    return sub {
        my ($url, $output) = @_;

        $curl->setopt(CURLOPT_URL       , $url);
        $curl->setopt(CURLOPT_WRITEDATA , $output);

        return $curl->perform;
    }
}

$| = 1;

my $list_only = 0;
if ($ARGV[0] eq "-l") {
    $list_only = 1;
    shift @ARGV;
}

for (@ARGV) {
    my ($board, $id) = m,4chan.org/(.*?)/thread/(\d*)(:?/.*)?,;

    my $dl = downloader({ CURLOPT_USERAGENT , 'Mozilla/5.0 (X11; Linux x86_64) Perl/5.18.1 curl/7.33.0' });

    my $url = "http://api.4chan.org/$board/thread/$id.json";
    my $json;
    next if $dl->($url, \$json) != 0;


    my $thread = decode_json(encode('utf-8', $json));

    for my $post (@{$thread->{posts}}) {
        next unless exists $post->{tim};

        my $filename = $post->{tim} . $post->{ext};


        my $url = "http://images.4chan.org/$board/src/$filename";
        if ($list_only) {
            say $url;
        } else {
            print "$url ... ";

            print "\e[1;33mEXISTS\e[0m\n" and next if -e $filename;

            my $image;
            if ($dl->($url, \$image) == 0) {
                print "\e[1;32mDONE\e[0m"
            } else {
                print "\e[1;31mERROR\e[0m"
            }

            open(my $file, '>', $filename) or next;
            print $file $image;
            close $file;
            print "\n";
        }
    }
}
