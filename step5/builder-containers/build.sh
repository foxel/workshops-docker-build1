#!/bin/bash

docker run --rm -v `pwd`/builder.sh:/opt/builder.sh \
    -v `pwd`:/output/ \
    node:8.6 /opt/builder.sh

docker build -t step5/builder . -f app.dockerfile
