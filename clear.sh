#!/bin/bash

TOOL_HOME=target/3rd

clear () {
    IMAGES=`cat $1|grep image|awk '{print $2}'|grep -v /`
    for image in $IMAGES; do
        docker rmi `echo $image|cut -d":" -f 1` -f
    done
}

docker-compose -f docker-compose.yml -f ${TOOL_HOME}/integration-tests-utils/docker-compose.yml down -v
rm -rf target
rm -rf data-mongo

clear docker-compose.yml
clear ${TOOL_HOME}/integration-tests-utils/docker-compose.yml