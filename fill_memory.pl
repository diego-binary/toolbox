use RedisDB;
use Data::Dumper;
use strict;
use warnings;

my $redis = RedisDB->new(host => 'localhost');


my $count = 0;
my $delta = time;
while ( 1 ) {
    $redis->hset('DUMMY::KEY::' . $count , $count , time );
    $count++;
    unless ( $count % 1000000 ) {
        $delta = time - $delta;
        print "Stored " . $count . " records in " . $delta . " [s]\n"  ;
        $delta = time;
    }
}


