#!/bin/bash

UTILS_DIR=integration-tests-utils
TOOL_HOME=target/3rd

configure() {
    if [ ! -e config/karate-config.js ]; then
        mkdir config
        cp ${TOOL_HOME}/${UTILS_DIR}/config/karate-config.js config/
        cp ${TOOL_HOME}/${UTILS_DIR}/config/docker-compose.yml .
    fi
}

start() {
    if [ "`docker ps|grep event-handler-generic`" = "" ]; then
        ${TOOL_HOME}/${UTILS_DIR}/start.sh
    fi
}

stop() {
    docker-compose -f docker-compose.yml -f ${TOOL_HOME}/integration-tests-utils/docker-compose.yml down -v
}

runTest(){
    if [ -d tests ] && [ "`docker ps|grep event-handler-generic`" != "" ]; then
        ${TOOL_HOME}/${UTILS_DIR}/runTests.sh
    else
        if [ "`docker ps|grep event-handler-generic`" = "" ]; then
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
    configure)
        configure
      ;;
    *)
        configure
        start
        runTest
     ;;
esac