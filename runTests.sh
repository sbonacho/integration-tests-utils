#!/bin/bash

source bin/xeda-integrations-utils/env.sh

docker exec -it mongodb mongo -u ${MONGO_USER} -p ${MONGO_PASS} ${MONGO_DB} --eval "${DROP_DATABASES}"

if [ ! -e "target/karate.jar" ]; then
    mkdir -p target
    curl -L -o target/karate.jar  ${KARATE_HOME}/karate-${KARATE_VERSION}.jar
fi

BASE_CLASSPATH=../../config:../../target/karate.jar

find ${TESTS_DIR} -name target|xargs rm -rf

if [ "$SMOKE_URL" != "" ]; then
    echo "Waiting for ${SMOKE_URL} availability"
    while [ "$CODE" != "200" ]; do
        CODE=`curl -s -I ${SMOKE_URL} |grep HTTP|awk '{print $2}'`
        echo -ne "."
        sleep 5
    done
else
    echo "No variable SMOKE_URL is defined in env.sh. You have to define it in order to wait to the environment availability"
fi

for epic in `ls ${TESTS_DIR}`; do
    echo "
****************************************
  Running Epic: $epic
****************************************

"
    CLASSPATH=${BASE_CLASSPATH}
    JIRA_SKIPPED=false
    if [ -e "${TESTS_DIR}/${epic}/epic.config" ]; then
        source ${TESTS_DIR}/${epic}/epic.config
        CLASSPATH=${CLASSPATH}:${CLASSPATH_ADDED}
    fi
    for feature in `ls ${TESTS_DIR}/${epic}|grep feature`; do
        cd ${TESTS_DIR}/${epic}
        java -cp $CLASSPATH com.intuit.karate.Main ${feature}
        cd -
    done

    if [ "${JIRA_SKIPPED}" = "false" ]; then
        for report in `ls ${TESTS_DIR}/${epic}/${ZEPHYR_REPORTS_DIR}|grep json|grep -v txt`; do
            java -jar ${ZEPHYR_JAR} \
             --username=${ZEPHYR_USER} \
             --password=${ZEPHYR_PASSWORD} \
             --reportType=${ZEPHYR_TYPE} \
             --projectKey=${ZEPHYR_PROJECT_KEY} \
             --releaseVersion=${ZEPHYR_RELEASE_VERSION} \
             --jiraUrl=${JIRA_URL} \
             --reportPath="${TESTS_DIR}/${epic}/${ZEPHYR_REPORTS_DIR}/${report}" \
             --testCycle="${epic}" \
             --linkType=Tests
         done
     fi

done