#!/bin/sh

dir=`dirname $0`

name="nas_ping_ext"

pingdest="www.google.com"
p1="$pingdest"
p2=`ping -c1 -W1 $pingdest | grep 'seq=' | sed 's/.*time=\([0-9]*\.[0-9]*\).*$/\1/'`
points="$p1 $p2"
$dir/todb2.sh "$name" "ping_google=$p2"

pingdest="speed.nia.or.kr"
p1="$pingdest"
p2=`ping -c1 -W1 $pingdest | grep 'seq=' | sed 's/.*time=\([0-9]*\.[0-9]*\).*$/\1/'`
points="$p1 $p2"
$dir/todb2.sh "$name" "ping_nia=$p2"
