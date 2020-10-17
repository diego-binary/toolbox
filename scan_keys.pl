use RedisDB;
use Data::Dumper;
use strict;
use warnings;

my $host = 'localhost';
my $port = $ARGV[0] // 6379;
print "Using $host:$port\n";
my $redis = RedisDB->new(host => $host, port => $port);

sub assemble_hash($) {
    my $arr_ref = shift;
    my %hash ;
    my $c = 0;
    for ( $arr_ref->@* ) {
        $hash{$_} = 1;
        #delete $arr_ref->[$c++]; 
    }
    return \%hash;
}

sub diff_hash($$) {
    my $hash = shift;
    my $prev_hash = shift;

    my %diff_hash;
    for (keys $hash->%*) {
        $diff_hash{$_} = $hash->{$_} unless defined $prev_hash->{$_} && $prev_hash->{$_} == $hash->{$_};
        #delete $hash->{$_};
    }
    return \%diff_hash;
}

my $prev_hash = {};
my $count = 0;
my $hash = {};
my $diff_hash = {};
my $deleted = {};
my $delta = 0;
my $key_count = 0;


while ( 1 ) {
    $delta = time;
    $hash = assemble_hash($redis->keys('*'));
    $key_count = scalar keys $hash->%*;
    $delta = time - $delta;
    #print "Assembled in $delta seconds\n";
    $delta = time;
    $diff_hash = diff_hash($hash, $prev_hash);
    $delta = time - $delta;
    #print "Added calc in $delta seconds\n";
    $delta = time;
    $deleted = diff_hash($prev_hash, $hash);
    $delta = time - $delta;
    #print "Deleted calc in $delta seconds\n";
    if ( $count > 0) {
        $delta = time;
        foreach (keys $diff_hash->%*) {
            next if $_ =~ /QUOTE/ ;
            print "+" .$_ . " => " . $diff_hash->{$_} . "\n";
            print "t = $count Found " . (scalar keys $diff_hash->%* ) . " new key(s). Total " . $key_count ." key(s).\n";
        }
        $delta = time - $delta;
        #print "Iterate Added in $delta seconds\n";
        $delta = time;
        foreach (keys %$deleted) {
            next if $_ =~ /QUOTE/ ;
            print "-" .$_ . " => " . $deleted->{$_} . "\n";
            print "t = $count Deleted " . (scalar keys %$deleted ) . " removed key(s). Total " .$key_count . " key(s) \n";
        }
        $delta = time - $delta;
        #print "Iterate Deleted in $delta seconds\n";
    }
    $prev_hash = $hash;
    $count++;
    sleep 1;
}


