#/bin/sh

dbname="grafana_asus"
dbhost="192.168.0.50:8086"

if [ $# -ne 2 ]; then
    echo "Usage: $0 \"series name\" \"column=value,...\""
    exit
fi

name="$1"
colnval="$2"

wget --quiet --post-data "$name $colnval" "http://$dbhost/write?db=$dbname" -O /dev/null

