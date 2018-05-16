#/bin/sh

dbname="grafana_nas"
dbhost="192.168.0.50:8086"

if [ $# -ne 2 ]; then
    echo "Usage: $0 \"series name\" \"column=value,...\""
    exit
fi

name="$1"
colnval="$2"

#wget --quiet --post-data "$name $colnval" "http://$dbhost/write?db=$dbname" -O /dev/null
#echo  "$name $colnval"
curl -i -XPOST "http://$dbhost/write?db=$dbname" --data "$name $colnval" > /dev/null 2>&1
