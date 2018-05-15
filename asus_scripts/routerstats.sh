#!/bin/sh

dir=`dirname $0`

nice -n -19 $dir/router_cpu.sh
sleep 1
nice -n -19 $dir/router_mem.sh
sleep 1
nice -n -19 $dir/router_net.sh
sleep 1
nice -n -19 $dir/router_ping_ext.sh
sleep 1
nice -n -19 $dir/router_temp.sh
sleep 1
nice -n -19 $dir/router_assoclist.sh
