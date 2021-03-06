#!/bin/bash

set -e

SCRIPTSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTSDIR/appimage

docker pull russelltg/chigraph-appimage:latest

DOCKER_PROCESS=$(docker run -d russelltg/chigraph-appimage:latest bash -c 'while true; do sleep 1000; done')

docker cp ./appimage_recipie.sh $DOCKER_PROCESS:/appimage_recipie.sh
docker exec $DOCKER_PROCESS bash /appimage_recipie.sh
docker cp $DOCKER_PROCESS:/chigraph.appdir/Chigraph-x86_64.AppImage ../../

docker kill $DOCKER_PROCESS
docker rm  $DOCKER_PROCESS

