#!/bin/sh

dir=`dirname $0`

name="router_temp"
columns="temp_24 temp_50 cpu"
p1=`wl -i eth1 phy_tempsense | awk '{ print $1 * .5 + 20 }'` # 2.4GHz
p2=`wl -i eth2 phy_tempsense | awk '{ print $1 * .5 + 20 }'` # 5.0GHz
pc=`cat /proc/dmu/temperature | head -n 1 | awk '{ print $4 + 0 }'` # cpu
points="temp_24=$p1,temp_50=$p2,cpu=$pc"
$dir/todb2.sh "$name" "$points"
