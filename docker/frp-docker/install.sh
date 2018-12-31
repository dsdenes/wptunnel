#!/usr/bin/env sh
FRP_VERSION=`git ls-remote https://github.com/fatedier/frp | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1`
KERNEL=`uname -s | awk '{print tolower($0)}'`
ARCH=`dpkg --print-architecture`
echo $FRP_VERSION $KERNEL $ARCH
wget -qO- https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_${KERNEL}_${ARCH}.tar.gz | tar xvz -C . --strip-components=1