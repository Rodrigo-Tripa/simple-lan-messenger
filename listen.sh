#!/bin/bash

PORT=5000

echo "[+] Simple LAN Chat v0.1.0"
echo "[+] Listening on port $PORT..."
echo "[+] Waiting for connection..."
echo

nc -lvnp "$PORT"