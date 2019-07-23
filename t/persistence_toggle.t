#!/usr/bin/perl

use strict;
use Test::More tests => 83007;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MemcachedTest;

my $engine = shift;
my $server = get_memcached($engine);
my $sock = $server->sock;


sub persistence_toggle {

    my $cmd = "config persistence";
    my $rst = "persistence off\r\nEND";
    mem_cmd_is($sock, $cmd, "", $rst);

    $cmd = "config persistence on";
    $rst = "END";
    mem_cmd_is($sock, $cmd, "", $rst);

    $cmd = "config persistence";
    $rst = "persistence on\r\nEND";
    mem_cmd_is($sock, $cmd, "", $rst);

    $cmd = "config persistence off";
    $rst = "END";
    mem_cmd_is($sock, $cmd, "", $rst);

    $cmd = "config persistence";
    $rst = "persistence off\r\nEND";
    mem_cmd_is($sock, $cmd, "", $rst);
}

sub handle_wrong_command {

}

persistence_toggle();




