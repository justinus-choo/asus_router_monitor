#!/bin/sh

dir=`dirname $0`

name="disk_usage"

volumes=`cat /etc/fstab | awk '{print $2}' | grep -v -w proc`

df --block-size=M $volumes | grep -v "^Filesystem" | awk '{print $6 "_total_mb=" $2 + 0 "," $6 "_used_mb=" $3 + 0 "," $6 "_avail_mb=" $4 + 0 }' | sed 's/\//_/g' | while read -r data; do
	$dir/todb2.sh "$name" "$data"
done

