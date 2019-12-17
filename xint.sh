#!/bin/bash

UTILS_DIR=integration-tests-utils
TOOL_HOME=target/3rd
TEST_CONTAINER=kafka-pixy

configure() {
    if [ ! -e config/karate-config.js ]; then
        mkdir config
        cp ${TOOL_HOME}/${UTILS_DIR}/config/karate-config.js config/
        cp ${TOOL_HOME}/${UTILS_DIR}/config/docker-compose.yml .
    fi
}

start() {
    if [ "`docker ps|grep ${TEST_CONTAINER}`" = "" ]; then
        ${TOOL_HOME}/${UTILS_DIR}/start.sh
    fi
}

stop() {
    docker-compose -f docker-compose.yml -f ${TOOL_HOME}/integration-tests-utils/docker-compose.yml down -v
}

reload(){
    if [[ "`docker images|grep -w $1`" !=  "" ]]; then
        docker-compose -f docker-compose.yml -f ${TOOL_HOME}/integration-tests-utils/docker-compose.yml stop $1
        rm -rf ${TOOL_HOME}/$1
        docker images|grep -w $1|awk '{print $3}'|xargs docker rmi -f
    fi
}

runTest(){
    if [ -d tests ] && [ "`docker ps|grep ${TEST_CONTAINER}`" != "" ]; then
        ${TOOL_HOME}/${UTILS_DIR}/runTests.sh
    else
        if [ "`docker ps|grep ${TEST_CONTAINER}`" = "" ]; then
            echo "

        ****************************
         Environment is not running
        ****************************

        "
        fi
        if [ ! -d tests ]; then
            echo "

        ****************************************
         Make sure that you have ./tests folder
        ****************************************

        "
        fi

    fi
}

case $1 in
    clear)
        ${TOOL_HOME}/${UTILS_DIR}/clear.sh
      ;;
    test)
        runTest
      ;;
    stop)
        stop
      ;;
    reload)
        reload $2
        ${TOOL_HOME}/${UTILS_DIR}/start.sh
      ;;
    configure)
        configure
      ;;
    *)
        configure
        start
        runTest
     ;;
esac