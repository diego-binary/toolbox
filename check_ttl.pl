#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

use RedisDB;

my $redis = RedisDB->new(host=>'localhost', port => '6379');

my $keys = $redis->keys('*');
for ($keys->@*) {
    print "No TTL for $_\n" unless $redis->ttl($_) >= 0;
}

print "Finished";