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

name="net"
columns="interface recv_kbps recv_errs recv_drop trans_kbps trans_errs trans_drop"

if [ -f $new ]; then
    awk -v old=$old -v interval=$interval -v maxint=$maxint '{
        getline line < old
        split(line, a)
        if( $1 == a[1] ) {
            recv_bytes  = $2 - a[2]
            trans_bytes = $5 - a[5]
            if(recv_bytes < 0) {recv_bytes = recv_bytes + maxint}    # maxint counter rollover
            if(trans_bytes < 0) {trans_bytes = trans_bytes + maxint} # maxint counter rollover
            recv_kbps  = (8 * (recv_bytes) / interval) / 1024     # kbits per second
            trans_kbps = (8 * (trans_bytes) / interval) / 1024    # kbits per second
            print $1"_recv_kbps=" recv_kbps ","$1"_recv_errs=" $3 - a[3] ","$1"_recv_drop=" $4 - a[4] ","$1"_trans_kbps=" trans_kbps ","$1"_trans_errs=" $6 - a[6] ","$1"_trans_drop=" $7 - a[7]

			if ( $1 == "eth0" ) {
				eth0_recv_kbps = recv_kbps
				eth0_trans_kbps = trans_kbps
			}
			if ( $1 == "vlan1" ) {
				wan_recv_kbps = eth0_recv_kbps - recv_kbps		# eth0 - vlan1
				wan_trans_kbps = eth0_trans_kbps - trans_kbps	# eth0 - vlan1
				print "wan_recv_kbps=" wan_recv_kbps ",wan_trans_kbps=" wan_trans_kbps
			}
        }
    }' $new  | while read val; do
        $dir/todb2.sh "$name" "$val"
        sleep 1
    done
    mv $new $old
fi

cat /proc/net/dev | tail +3 | tr ':|' '  ' | awk '{print $1,$2,$4,$5,$10,$12,$13}' > $new
