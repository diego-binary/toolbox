#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

use RedisDB;

my $redis = RedisDB->new(host=>'localhost', port => '6379');

my $is_scan = ($ARGV[0] // 'no') eq 'scan';

my $cursor = 0;

if (!$is_scan) {
    print "Using keys\n";
    my $keys = $redis->keys('DUMMY::KEY*');
    for ($keys->@*) {
        print "Removing $_\n";
        $redis->del($_);
    }
} else{
    print "Using scan\n";
    ($cursor, my $all_keys) = $redis->scan($cursor, match => 'DUMMY::KEY::*')->@*;

    print Dumper($all_keys) unless defined $cursor;
    do {
        print "Cursor is $cursor\n";
        for ($all_keys->@*) {
            print "Removing $_\n";
            $redis->del($_);
        }
        ($cursor, $all_keys) = $redis->scan($cursor)->@*;
    } while($cursor);
}

print "Finished";