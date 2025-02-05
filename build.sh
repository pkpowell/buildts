#!/bin/bash
default_branch="main"
default_service="system/com.tailscale.tailscaled"

# echo "checking if $1 exists"
if test -f "$1"; then
    # echo "$1 exists"
    source $1
else
    source defaultconf
fi

if [[ -z $branch ]]; then 
    branch=$default_branch
fi

if [[ -f "service_name" ]]; then 
    source service_name
fi

if [[ -z $service ]]; then 
    service=$default_service
fi

echo "branch $branch"
echo "service $service"

if [ ! -d "./tailscale" ]; then
    git clone https://github.com/tailscale/tailscale.git tailscale
fi

cd ./tailscale

if [ $branch ]; then
    echo "switching to branch $branch"
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