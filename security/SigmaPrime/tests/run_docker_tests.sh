#!/bin/sh

HERE="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
# Builds and runs the tests via Docker.

# Check for one param
if [ "$#" -ne 1 ]
then
  echo "Requires RPC URL for Avalanche to be passed as a param: './run_docker_tests.sh https://avalanche-mainnet.infura.io/v3/1234..."
  exit 1
fi

# Set the build context to the parent directory
cd $HERE/../ && docker build --build-arg INFURA_URL=$1 -f tests/Dockerfile -t review-testing . && docker run -it review-testing