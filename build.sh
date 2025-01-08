#!/bin/bash

if [ $1 ]; then
    source $1
else
    source config
fi

echo "branch $branch"
echo "service $service"

if [ ! -d "./tailscale" ]; then
    git clone https://github.com/tailscale/tailscale.git tailscale
fi

cd ./tailscale

if [ $branch ]; then
    echo "switching to branch $1"
    git switch $branch
else
    git switch main
fi

git pull

sh ./build_dist.sh tailscale.com/cmd/tailscaled && {
    echo "tailscaled build ok"
} || {
    echo "build tailscale.com/cmd/tailscaled failed"
    exit $?
}

sh ./build_dist.sh tailscale.com/cmd/tailscale && {
    echo "tailscale build ok"
} || {
    echo "build tailscale.com/cmd/tailscale failed"
    exit $?
}

ln -sf $PWD/tailscale* /usr/local/bin/

sudo launchctl kickstart -k $service
tailscale version

echo ""
echo "Done"