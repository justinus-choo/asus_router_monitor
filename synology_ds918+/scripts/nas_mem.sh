#!/bin/sh

dir=`dirname $0`

name="mem"
scriptname=`basename $0`
tmp="/tmp/${scriptname}.data"

cat /proc/meminfo > $tmp
total=`head -n1 $tmp | awk '{print $2}'`
free=`head -n2 $tmp | tail -n1 | awk '{print $2}'`
buffer=`head -n4 $tmp | tail -n1 | awk '{print $2}'`
cached=`head -n5 $tmp | tail -n1 | awk '{print $2}'`
used=`expr $total - $free - $buffer - $cached`

colnval="total_kb=$total,free_kb=$free,buffer_kb=$buffer,cached_kb=$cached,used_kb=$used"
$dir/todb2.sh "$name" "$colnval"
