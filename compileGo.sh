#!/bin/sh

apk update && apk add --no-cache git bash alpine-sdk openssh-client && rm -rf /var/cache/apk/*
go get -u github.com/golang/dep/...
eval $(ssh-agent -s)

git config --global url."ssh://git@gitlab.com/OrangeX/".insteadOf "https://gitlab.com/OrangeX/"
echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

cd $2
dep ensure
mkdir build
go build -v -o build/$1

echo "Go App compiled!!"