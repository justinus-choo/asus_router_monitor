#!/bin/sh

maxint=4294967295
dir=`dirname $0`
scriptname=`basename $0`
old="/tmp/$scriptname.data.old"
new="/tmp/$scriptname.data.new"
old_epoch_file="/tmp/$scriptname.epoch.old"

old_epoch=`cat $old_epoch_file`
new_epoch=`date "+%s"`
echo $new_epoch > $old_epoch_file

interval=`expr $new_epoch - $old_epoch` # seconds since last sample

name="diskio"

mv $new $old
cat /proc/diskstats | grep "md[0-9]" | awk '{print $3,$4,$6,$8,$10}' > $new

if [ -f $old ]; then
    awk -v old=$old -v interval=$interval -v maxint=$maxint '{
        getline line < old
        split(line, a)
        if( $1 == a[1] ) {
			reads = $2 - a[2]
            read_sectors  = $3 - a[3]
			writes = $4 - a[4]
            write_sectors = $5 - a[5]

            if(reads < 0) {reads = reads + maxint}    # maxint counter rollover
            if(read_sectors < 0) {read_sectors = read_sectors + maxint}    # maxint counter rollover
            if(writes < 0) {writes = writes + maxint}    # maxint counter rollover
            if(write_sectors < 0) {write_sectors = write_sectors + maxint} # maxint counter rollover

			sector_size = 512
			read_tps = reads / interval
			write_tps = writes / interval

            read_BPS = ((read_sectors * sector_size) / interval)      # kbytes per second
            write_BPS = ((write_sectors * sector_size) / interval)    # kbytes per second

            print $1"_read_BPS=" read_BPS ","$1"_read_tps=" read_tps ","$1"_write_BPS=" write_BPS ","$1"_write_tps=" write_tps

        }
    }' $new  | while read val; do
        $dir/todb2.sh "$name" "$val"
    done
fi

