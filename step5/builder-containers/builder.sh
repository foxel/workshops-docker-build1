#!/bin/sh

set -e

export HOME=/src/app
mkdir -p $HOME

cd $HOME

repository="Ismaestro/angular4-example-app"

wget -qO- https://github.com/${repository}/archive/master.tar.gz | \
    tar -xz --strip-components=1 -C $HOME

npm install
npm run build

tar -czf /output/app.tar.gz -C $HOME/dist .
