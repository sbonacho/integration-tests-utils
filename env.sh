#!/usr/bin/env bash

TARGET="target/3rd"
TESTS_DIR="tests"
REPOS="
git@gitlab.com:OrangeX/BPM/mysql-activiti.git
git@gitlab.com:OrangeX/backend/xeda/event-handler-generic.git?master?java11mvn
git@gitlab.com:OrangeX/backend/xeda/xbyorange-finder.git?master?java11mvn
git@gitlab.com:OrangeX/backend/kafka/xeda-kafka-schemas.git?develop
git@gitlab.platform.xbyorange.com:xbyorange/mobile/mobile-file-reader.git?master?java8mvn
"

# Karate

KARATE_VERSION=0.9.4
KARATE_HOME=https://dl.bintray.com/ptrthomas/karate

# Zephyr

ZEPHYR_VERSION=0.0.14
ZEPHYR_JAR=${TARGET}/integration-tests-utils/lib/zephyr-sync-cli-${ZEPHYR_VERSION}-SNAPSHOT-all-in-one.jar
ZEPHYR_USER=${JIRA_BOT_USER}
ZEPHYR_PASSWORD=${JIRA_BOT_PASSWORD}
ZEPHYR_TYPE=cucumber
ZEPHYR_PROJECT_KEY=ORXPMO
ZEPHYR_RELEASE_VERSION="no-release"
ZEPHYR_REPORTS_DIR=target/surefire-reports

# Jira

JIRA_URL=https://jira.si.orange.es/rest/

# Gitlab

GITLAB_HOST=gitlab-registry.platform.xbyorange.com

# Mongo Connection

MONGO_USER=admin
MONGO_PASS=admin
MONGO_DB=admin
DROP_DATABASES="db.getMongo().getDBNames().forEach(function(x) {if (['admin', 'config', 'local'].indexOf(x) < 0) {db.getMongo().getDB(x).dropDatabase(); } })"

if [ -e env.sh ]; then
    source env.sh
fi