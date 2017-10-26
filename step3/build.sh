#!/bin/bash

docker build -t docker1/step2/final . -f final.dockerfile

docker build -t docker1/step2/child . -f child.dockerfile
