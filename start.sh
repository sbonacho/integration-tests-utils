#!/bin/bash

. ~/.sdkman/bin/sdkman-init.sh

source target/3rd/integration-tests-utils/env.sh

if [[ "`echo ${REPOS}|grep ?go`" != "" ]]; then
    REPOS="${REPOS}
git@gitlab.com:OrangeX/System/tools/golang-kafka-image.git?master?dockerbuild"
fi

if [[ "${GITLAB_HOST}" != "" ]]; then
    docker login ${GITLAB_HOST}
    if [ "$?" -ne 0 ]; then
        echo "must to be logged on ${GITLAB_HOST}"
        exit -1
    fi
fi

if [[ ! -d $TARGET ]]; then
    mkdir -p $TARGET
fi

javamvn() {
    if [[ "`find $1 -name target`" = "" ]]; then
        sdk use java $3
        mvn -f $1 clean package -DskipTest
    fi
}
go() {
    if [[ "`docker images|grep $1`" =  "" ]]; then
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
    if [[ "`docker images|grep -sw $1`" =  "" ]]; then
        docker build $1 -t $1
    fi
}

cd $TARGET

for repoline in $REPOS; do
    REPO=`echo $repoline|cut -d"?" -f 1`
    BRANCH=`echo $repoline|cut -d"?" -f 2`
    BUILD=`echo $repoline|cut -d"?" -f 3`
    VERSION=`echo $repoline|cut -d"?" -f 4`
    DIR=`echo $REPO|rev | cut -d"/" -f 1 | rev|cut -d"." -f 1`
    if [[ "`echo $repoline|grep ?`" != "" ]]; then
        if [[ ! -d $DIR ]]; then
            git clone -b $BRANCH $REPO
        fi
        if [[ "`echo $BUILD`" != "" ]]; then
            $BUILD $DIR $REPO $VERSION
        fi
    else
        if [[ ! -d $DIR ]]; then
            git clone $REPO
        fi
    fi
done

cd -

if [[ "`docker network ls|grep xeda-local`" =  "" ]]; then
    docker network create xeda-local
fi
docker-compose -f docker-compose.yml -f ${TARGET}/integration-tests-utils/docker-compose.yml up -d