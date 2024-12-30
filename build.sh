#!/bin/bash

if [ ! -d "./tailscale" ]; 
    git clone https://github.com/tailscale/tailscale.git tailscale
else 
    git -C ./tailscale pull origin main
fi

sh ./tailscale/build_dist.sh tailscale.com/cmd/tailscaled && {
    echo "tailscale.com/cmd/tailscaled ok"
} || {
    echo "build tailscale.com/cmd/tailscaled failed"
    exit $?
}

sh ./tailscale/build_dist.sh tailscale.com/cmd/tailscale && {
    echo "tailscale.com/cmd/tailscale ok"
} || {
    echo "build tailscale.com/cmd/tailscale failed"
    exit $?
}