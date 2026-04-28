#!/bin/bash

PORT=5000
TARGET_IP="$1"

if [ -z "$TARGET_IP" ]; then
    echo "Usage: ./connect.sh <target-ip>"
    echo "Example: ./connect.sh 192.168.1.15"
    exit 1
fi

echo "[+] Simple LAN Chat v0.1.0"
echo "[+] Connecting to $TARGET_IP:$PORT..."
echo

nc "$TARGET_IP" "$PORT"