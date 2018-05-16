#!/bin/sh

dir=`dirname $0`

name="nas_cpu"
colnvalue=`top -bn2 -d3 | grep "^%Cpu" | tail -n1 | awk '{print "usr=" $2 ",sys=" $4 ",nic=" $6 ",idle=" $8 ",io=" $10 ",irq=" $12 ",sirq=" $14 ",steal=" $16}' | sed 's/%//g'`
$dir/todb2.sh "$name" "$colnvalue"

name="nas_loadavg"
colnvalue=`cat /proc/loadavg | head -n 1 | awk '{print "1min=" $1 ",5min=" $2 ",15min=" $3 }'`
$dir/todb2.sh "$name" "$colnvalue"
