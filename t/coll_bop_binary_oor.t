#!/usr/bin/perl

use strict;
use Test::More tests => 88;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MemcachedTest;

my $engine = shift;
my $server = get_memcached($engine);
my $sock = $server->sock;

my $cmd;
my $rst;

sub binary_key_insert {
    my ($key, $bkeys_ref) = @_;
    my @bkeys = @{$bkeys_ref};

    for (my $i = 0; $i < $#bkeys+1; $i++) {
        my $cmd = "bop insert $key $bkeys[$i] 6";
        my $val = "datum$i";
        mem_cmd_is($sock, $cmd, $val, "STORED");
    }

}

#test1. all binary(hex) bkeys have same length
#maxbkeyrange = 50
#insert (100, 110, 120, 130, 140, 150) first.
#then, insert 0, 255
mem_cmd_is($sock, "bop create fixed_len_key_btree 0 0 0", "", "CREATED");
mem_cmd_is($sock, "setattr fixed_len_key_btree maxbkeyrange=0x32", "", "OK");
my @fixed_length_bkey = ("0x64", "0x6E", "0x78", "0x82", "0x8C", "0x96");
binary_key_insert("fixed_len_key_btree", \@fixed_length_bkey);
mem_cmd_is($sock, "setattr fixed_len_key_btree overflowaction=smallest_trim", "", "OK");
mem_cmd_is($sock, "bop insert fixed_len_key_btree 0x00 6", "datum6", "OUT_OF_RANGE");
mem_cmd_is($sock, "setattr fixed_len_key_btree overflowaction=largest_trim", "", "OK");
mem_cmd_is($sock, "bop insert fixed_len_key_btree 0xFF 6", "datum7", "OUT_OF_RANGE");

#test2. all binary(hex) bkeys have different length
#maxbkeyrange = 50
#insert (100, 110, 120, 130, 140, 150) first.
#then, insert 0, 255
mem_cmd_is($sock, "bop create variable_len_key_btree 0 0 0", "", "CREATED");
mem_cmd_is($sock, "setattr variable_len_key_btree maxbkeyrange=0x32", "", "OK");
my @variable_length_bkey = ("0x0064", "0x00006E", "0x00000078", "0x0000000082", "0x00000000008C", "0x00000000000096");
binary_key_insert("variable_len_key_btree", \@variable_length_bkey);
mem_cmd_is($sock, "setattr variable_len_key_btree overflowaction=smallest_trim", "", "OK");
mem_cmd_is($sock, "bop insert variable_len_key_btree 0x00 6", "datum6", "OUT_OF_RANGE");
mem_cmd_is($sock, "setattr variable_len_key_btree overflowaction=largest_trim", "", "OK");
mem_cmd_is($sock, "bop insert variable_len_key_btree 0xFF 6", "datum7", "OUT_OF_RANGE");

release_memcached($engine, $server);
