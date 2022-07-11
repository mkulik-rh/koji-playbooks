#!/bin/bash
path="/usr/sbin/kojid-dev/"
firstmd5=`ls -laR $path | md5sum | awk ' { print $1 }'`

while true
do
    lastmd5=`ls -laR $path | md5sum | awk ' { print $1 }'`
    if [ $firstmd5 !=  $lastmd5 ]
    then
        firstmd5=lastmd5
        systemctl restart kojid
    fi
    sleep 1
done