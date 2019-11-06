#!/bin/bash

. ~/.sdkman/bin/sdkman-init.sh

source target/3rd/integration-tests-utils/env.sh

if [ "`echo ${REPOS}|grep ?go`" != "" ]; then
    REPOS="${REPOS}
git@gitlab.com:OrangeX/System/tools/golang-kafka-image.git?master?dockerbuild"
fi

docker login ${GITLAB_HOST}
if [ "$?" -ne 0 ]; then
    echo "must to be logged on ${GITLAB_HOST}"
    exit -1
fi

if [ ! -d $TARGET ]; then
    mkdir -p $TARGET
fi

java11mvn() {
    if [ "`find $1 -name target`" = "" ]; then
        sdk use java 11.0.2-open
        mvn -f $1 clean package -DskipTest
    fi
}

java8mvn() {
    if [ "`find $1 -name target`" = "" ]; then
        sdk use java 8.0.202-zulu
        mvn -f $1 clean package -DskipTest
    fi
}

go() {
    if [ "`docker images|grep $1`" =  "" ]; then
        RAIZ="/go/`echo $2|sed 's/git@gitlab.com:OrangeX/src\/gitlab.com/'|sed 's/\.git//'`"
        cat $1/Dockerfile|grep -v FROM|sed '1s/^/FROM golang-kafka-image|/'|tr '|' '\n' > $1/Dockerfile.tmp
        mv $1/Dockerfile.tmp $1/Dockerfile
        cp ../../compileGo.sh $1
        cd $1
        docker run -ti --rm -v `pwd`:/$RAIZ -v ~/.ssh:/root/.ssh --entrypoint=/$RAIZ/compileGo.sh golang-kafka-image $1 $RAIZ
        cd ..
    fi
}

dockerbuild() {
    if [ "`docker images|grep $1`" =  "" ]; then
        docker build $1 -t $1
    fi
}

cd $TARGET

for repoline in $REPOS; do
    REPO=`echo $repoline|cut -d"?" -f 1`
    BRANCH=`echo $repoline|cut -d"?" -f 2`
    BUILD=`echo $repoline|cut -d"?" -f 3`
    DIR=`echo $REPO|rev | cut -d"/" -f 1 | rev|cut -d"." -f 1`
    if [ "`echo $repoline|grep ?`" != "" ]; then
        git clone -b $BRANCH $REPO
        if [ "`echo $BUILD`" != "" ]; then
            $BUILD $DIR $REPO
        fi
    else
        git clone $REPO
    fi
done

find . -name .git| xargs rm -rf
cd -

if [ "`docker network ls|grep xeda-local`" =  "" ]; then
    docker network create xeda-local
fi
docker-compose -f docker-compose.yml -f ${TARGET}/integration-tests-utils/docker-compose.yml up -d