#!/bin/sh

# wl sta_info F8:16:54:8F:F6:6A

dir=`dirname $0`

name="router_assoclist_24"
columns="count"
p1=`wl -i eth1 assoclist | awk '{print $2}' | wc -l`
points="$p1"
$dir/todb2.sh "$name" "$columns=$points"

name="router_assoclist_50"
columns="count"
p1=`wl -i eth2 assoclist | awk '{print $2}' | wc -l`
points="$p1"
$dir/todb2.sh "$name" "$columns=$points"
