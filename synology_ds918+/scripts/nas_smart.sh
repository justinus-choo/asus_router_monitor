#!/bin/sh

dir=`dirname $0`

name="nas_smart"

DEVICES="sda sdb sdc sdd"

for dev in $DEVICES; do
	/bin/smartctl -a -d ata /dev/$dev > /tmp/smart.$dev

	temp=`grep "^194 Temperature_Celsius" /tmp/smart.$dev | awk '{print $10}'`
	$dir/todb2.sh "$name" "${dev}_temperature=$temp"

	realloc=`grep "^  5 Reallocated_Sector_Ct" /tmp/smart.$dev | awk '{print $10}'`
	pending=`grep "^197 Current_Pending_Sector" /tmp/smart.$dev | awk '{print $10}'`
	uncorrectable=`grep "198 Offline_Uncorrectable" /tmp/smart.$dev | awk '{print $10}'`
	(( bad_sectors = realloc + pending + uncorrectable ))
	$dir/todb2.sh "$name" "${dev}_realloc=$realloc,${dev}_pending=$pending,${dev}_uncorrectable=$uncorrectable,${dev}_bad_sectors=$bad_sectors"

	/bin/rm -f /tmp/smart.$dev
done


#$dir/todb2.sh "$name" "ping_nia=$p2"
