#!/bin/bash

# Name: Simple LAN Chat
# Author: Rodrigo-Tripa (GitHub)
# Description: Peer-to-peer minimalist chat for local networks.
# Version: 0.4.0

VERSION="0.4.0"
PORT=5000
LOG_FILE="chat_history_$(date +%Y%m%d_%H%M%S).log"
ENABLE_LOGGING=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════╗"
    echo "║     Simple LAN Chat - Server Mode    ║"
    echo "║            Version $VERSION              ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Help menu
show_help() {
    echo -e "${YELLOW}Usage:${NC} $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --port <PORT>     Specify port (default: 5000)"
    echo "  -l, --log             Enable chat logging"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    Start server on default port 5000"
    echo "  $0 -p 8080            Start server on port 8080"
    echo "  $0 -p 5000 -l         Start with logging enabled"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -l|--log)
            ENABLE_LOGGING=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}[!] Unknown option: $1${NC}"
            show_help
            ;;
    esac
done

# Validate port
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo -e "${RED}[!] Error: Invalid port number. Must be between 1-65535${NC}"
    exit 1
fi

# Check if port is available
if ss -tuln | grep -q ":$PORT "; then
    echo -e "${RED}[!] Error: Port $PORT is already in use${NC}"
    echo -e "${YELLOW}[*] Processes using port $PORT:${NC}"
    ss -tulpn 2>/dev/null | grep ":$PORT " || ss -tuln | grep ":$PORT "
    exit 1
fi

# Check for netcat
if ! command -v nc &> /dev/null; then
    echo -e "${RED}[!] Error: netcat (nc) is not installed${NC}"
    echo -e "${YELLOW}[*] Install with:${NC}"
    echo "    Debian/Ubuntu: sudo apt install netcat-openbsd"
    echo "    RHEL/Fedora:   sudo dnf install nmap-ncat"
    echo "    Arch Linux:    sudo pacman -S gnu-netcat"
    exit 1
fi

# Get local IP
LOCAL_IP=$(hostname -I | awk '{print $1}')
if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
fi

# Show banner and info
show_banner
echo -e "${GREEN}[+]${NC} Server Mode Activated"
echo -e "${GREEN}[+]${NC} Listening on: ${CYAN}$LOCAL_IP:$PORT${NC}"
echo -e "${GREEN}[+]${NC} Waiting for connection..."

if [ "$ENABLE_LOGGING" = true ]; then
    echo -e "${GREEN}[+]${NC} Logging enabled: ${CYAN}$LOG_FILE${NC}"
fi

echo ""
echo -e "${YELLOW}[*]${NC} Client should connect with:"
echo -e "    ${CYAN}./connect.sh $LOCAL_IP${NC}"
if [ "$PORT" != "5000" ]; then
    echo -e "    ${CYAN}./connect.sh $LOCAL_IP -p $PORT${NC}"
fi
echo ""
echo -e "${YELLOW}[*]${NC} Press ${RED}Ctrl+C${NC} to stop server or type ${RED}/quit${NC} to exit"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -n "Enter your username: "
read -r USERNAME

# Cleanup function for graceful exit
cleanup() {
    echo ""
    echo -e "${YELLOW}[*]${NC} Server stopped"
    if [ "$ENABLE_LOGGING" = true ]; then
        echo -e "${GREEN}[+]${NC} Chat log saved: ${CYAN}$LOG_FILE${NC}"
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start listening
if [ "$ENABLE_LOGGING" = true ]; then
    {
        echo "=== Chat Session Started ==="
        echo "Date: $(date)"
        echo "Port: $PORT"
        echo "Username: $USERNAME"
        echo "============================="
        echo ""
    } > "$LOG_FILE"
fi

FIFO="/tmp/chat_fifo_listen_$$"
mkfifo "$FIFO"
nc -lnv "$PORT" < "$FIFO" | (
    while read -r line; do
        echo "$line"
        if [ "$ENABLE_LOGGING" = true ]; then
            echo "$line" >> "$LOG_FILE"
        fi
    done
) &
NC_PID=$!

echo "[$USERNAME is now listening]" > "$FIFO"

while read -r line; do
    if [ "$line" = "/quit" ]; then
        echo "[$USERNAME stopped listening]" > "$FIFO"
        break
    fi
    timestamp=$(date +%H:%M:%S)
    echo "[$timestamp] $USERNAME: $line" > "$FIFO"
    if [ "$ENABLE_LOGGING" = true ]; then
        echo "[$timestamp] $USERNAME: $line" >> "$LOG_FILE"
    fi
done

wait $NC_PID
rm "$FIFO"
