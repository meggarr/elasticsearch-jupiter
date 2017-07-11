#!/bin/bash

set -e

function usage() {
  echo "Usage: $0 -h -f -c <config-json> -l <log-config> -d"
  echo "Options:"
  echo " -h|--help                     Print help instructions"
  echo " -i|--image                    The Docker image name"
  echo " -t|--tag                      The Docker image version (tag)"
  exit 1
}

[ "X$IMAGE_NAME" = "X" ] && IMAGE_NAME="elasticsearch2"
[ "X$IMAGE_TAG" = "X" ] && IMAGE_TAG="dev"

while [[ $# > 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
    usage
    ;;

    -i|--image)
    IMAGE_NAME="$2"
    shift # past argument
    ;;

    -t|--tag)
    IMAGE_TAG="$2"
    shift # past argument
    ;;

    *)
    ;;
  esac
  shift # past argument or value
done

printf "\n[-] Building $IMAGE_NAME:$IMAGE_TAG...\n\n"

docker build -t $IMAGE_NAME:$IMAGE_TAG .

