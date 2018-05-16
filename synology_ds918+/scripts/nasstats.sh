#!/bin/sh

dir=`dirname $0`

nice -n -19 $dir/nas_cpu.sh
sleep 1
nice -n -19 $dir/nas_mem.sh
sleep 1
nice -n -19 $dir/nas_net.sh
sleep 1
nice -n -19 $dir/nas_ping_ext.sh
sleep 1
nice -n -19 $dir/nas_diskusage.sh
sleep 1
nice -n -19 $dir/nas_diskio.sh
