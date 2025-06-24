#!/bin/sh

set -e

# 目标存放目录
TARGET_DIR="/usr/share/v2ray"
mkdir -p "$TARGET_DIR"

# 下载地址（与 update.sh 保持一致）
GEOIP_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat"
GEOSITE_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"

# 下载 geoip.dat
curl -L -o "$TARGET_DIR/geoip.dat" "$GEOIP_URL"

# 下载 geosite.dat
curl -L -o "$TARGET_DIR/geosite.dat" "$GEOSITE_URL"

echo "geodata update finished: $TARGET_DIR"
