use RedisDB;
use Data::Dumper;
use strict;
use warnings;

my $redis = RedisDB->new(host => 'localhost');

sub assemble_hash($) {
    my @arr = shift->@*;
    my %hash ;
    map { $hash{$_} = ($hash{$_} // 0) + 1 } @arr;
    return \%hash;
}

sub diff_hash($$) {
    my %hash = shift->%*;
    my %prev_hash = shift->%*;

    my %diff_hash;
    map { $diff_hash{$_} = $hash{$_} unless defined $prev_hash{$_} && $prev_hash{$_} == $hash{$_}  } keys %hash;
    return \%diff_hash;
}

my %prev_hash;
my $count = 0;

while ( 1 ) {
    $redis->hset('DUMMY::KEY', $count , time );
    $count++;
    #sleep 1;
}


