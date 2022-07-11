#!/bin/bash
path="/usr/share/koji-hub-develop/"
firstmd5=`ls -laR $path | md5sum | awk ' { print $1 }'`

while true
do
    lastmd5=`ls -laR $path | md5sum | awk ' { print $1 }'`
    if [ $firstmd5 !=  $lastmd5 ]
    then
        firstmd5 = lastmd5
        systemctl restart httpd
    fi
    sleep 1
done