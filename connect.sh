#!/bin/bash

# Name: Simple LAN Chat
# Author: Rodrigo-Tripa (GitHub)
# Description: Peer-to-peer minimalist chat for local networks.
# Version: 0.3.5

VERSION="0.3.5"
PORT=5000
TARGET_IP=""
LOG_FILE="chat_history_$(date +%Y%m%d_%H%M%S).log"
ENABLE_LOGGING=false
TIMEOUT=5

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
    echo "║     Simple LAN Chat - Client Mode    ║"
    echo "║            Version $VERSION              ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Help menu
show_help() {
    echo -e "${YELLOW}Usage:${NC} $0 <TARGET_IP> [OPTIONS]"
    echo ""
    echo "Arguments:"
    echo "  TARGET_IP             IP address of the server"
    echo ""
    echo "Options:"
    echo "  -p, --port <PORT>     Specify port (default: 5000)"
    echo "  -l, --log             Enable chat logging"
    echo "  -t, --timeout <SEC>   Connection timeout in seconds (default: 5)"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 192.168.1.15"
    echo "  $0 192.168.1.15 -p 8080"
    echo "  $0 192.168.1.15 -l -t 10"
    exit 0
}

# Validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if [ "$octet" -gt 255 ]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
fi

TARGET_IP="$1"
shift

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
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
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

# Validate target IP
if ! validate_ip "$TARGET_IP"; then
    echo -e "${RED}[!] Error: Invalid IP address format${NC}"
    echo -e "${YELLOW}[*] Example:${NC} $0 192.168.1.15"
    exit 1
fi

# Validate port
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo -e "${RED}[!] Error: Invalid port number. Must be between 1-65535${NC}"
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

# Show banner and info
show_banner
echo -e "${GREEN}[+]${NC} Client Mode Activated"
echo -e "${GREEN}[+]${NC} Target: ${CYAN}$TARGET_IP:$PORT${NC}"

if [ "$ENABLE_LOGGING" = true ]; then
    echo -e "${GREEN}[+]${NC} Logging enabled: ${CYAN}$LOG_FILE${NC}"
fi

echo ""

# Test connectivity
echo -e "${YELLOW}[*]${NC} Testing connectivity..."
if timeout "$TIMEOUT" bash -c "echo > /dev/tcp/$TARGET_IP/$PORT" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} Connection successful!"
else
    echo -e "${RED}[!]${NC} Connection failed!"
    echo ""
    echo -e "${YELLOW}[*] Troubleshooting:${NC}"
    echo "    1. Verify server is running: ./listen.sh"
    echo "    2. Check firewall settings"
    echo "    3. Verify IP address: $TARGET_IP"
    echo "    4. Ping test: ping $TARGET_IP"
    exit 1
fi

echo -e "${YELLOW}[*]${NC} Press ${RED}Ctrl+C${NC} to disconnect"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}[*]${NC} Disconnected from server"
    if [ "$ENABLE_LOGGING" = true ]; then
        echo -e "${GREEN}[+]${NC} Chat log saved: ${CYAN}$LOG_FILE${NC}"
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start connection
if [ "$ENABLE_LOGGING" = true ]; then
    {
        echo "=== Chat Session Started ==="
        echo "Date: $(date)"
        echo "Target: $TARGET_IP:$PORT"
        echo "============================="
        echo ""
    } > "$LOG_FILE"

    nc -nv "$TARGET_IP" "$PORT" | tee -a "$LOG_FILE"
else
    nc -nv "$TARGET_IP" "$PORT"
fi
