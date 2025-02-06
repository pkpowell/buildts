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
    source service_name.sh
fi

if [[ -z $service ]]; then 
    service=$default_service
fi

# echo "branch $branch"
# echo "service $service"

if [ ! -d "./tailscale" ]; then
    echo "Cloning repo"
    git clone https://github.com/tailscale/tailscale.git tailscale > /dev/null 2>&1
fi

cd ./tailscale

if [ $branch ]; then
    echo "Switching to branch $branch"
    git switch $branch > /dev/null 2>&1
else
    git switch main > /dev/null 2>&1
fi

echo "Pulling repo changes"
git pull > /dev/null 2>&1

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

echo "Linking taiscale binaries to /usr/local/bin/"
ln -sf $PWD/tailscale* /usr/local/bin/

echo "Restarting taiscaled service $service"
sudo launchctl kickstart -k $service

tailscale version

echo ""
echo "Done"