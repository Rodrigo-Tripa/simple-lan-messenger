# Simple LAN Chat

![Version](https://img.shields.io/badge/version-0.4.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)

Peer-to-peer minimalist chat for local networks. Zero configuration, zero extra dependencies.

---

## 🚀 Quick Start

```bash
# Server (Machine A)
./listen.sh

# Client (Machine B)
./connect.sh 192.168.1.15
```

---

## ✨ Features

- **Colorful interface** with banner and visual status
- **Automatic IP and port validation**
- **Connectivity test** before connecting
- **Optional logging** of conversations (`-l`)
- **Customizable ports** via `-p`
- **Automatic local IP detection**
- **Complete help menu** (`-h`)
- **Robust error handling**
- **Username support** with custom nicknames
- **Timestamps** on all messages
- **Graceful exit** with /quit command
- **Enhanced logging** including sent messages

---

## 📋 Usage

### Server (listen for connections)

```bash
./listen.sh                  # Default port 5000
./listen.sh -p 8080          # Custom port
./listen.sh -l               # With logging
./listen.sh -p 5000 -l       # Port + logging
```

### Client (connect to server)

```bash
./connect.sh 192.168.1.15              # Default port 5000
./connect.sh 192.168.1.15 -p 8080      # Custom port
./connect.sh 192.168.1.15 -l           # With logging
./connect.sh 192.168.1.15 -t 10        # Timeout 10s
```

### Available Options

| Option          | Description                              |
|----------------|------------------------------------------|
| `-p, --port`   | TCP port (default: 5000)                |
| `-l, --log`    | Save history to file                     |
| `-t, --timeout`| Connection timeout (client only)        |
| `-h, --help`   | Show help                               |

---

## 📦 Installation

```bash
git clone https://github.com/Rodrigo-Tripa/simple-lan-chat.git
cd simple-lan-chat
chmod +x listen.sh connect.sh
```

**Dependencies:**
- Linux (Kernel 2.6+)
- Bash 4.0+
- netcat (`nc`)

If `netcat` is not installed:

```bash
# Debian/Ubuntu
sudo apt install netcat-openbsd

# RHEL/Fedora
sudo dnf install nmap-ncat

# Arch Linux
sudo pacman -S gnu-netcat
```

---

## 🔧 Troubleshooting

### "Port already in use"
```bash
# Check processes on port
ss -tulpn | grep 5000

# Use alternative port
./listen.sh -p 5001
```

### "Connection failed"
```bash
# Check connectivity
ping 192.168.1.15

# Open port in firewall
sudo ufw allow 5000/tcp
```

### "nc: command not found"
```bash
# Install netcat
sudo apt install netcat-openbsd
```

---

## 🔐 Security

⚠️ **WARNINGS:**
- **Unencrypted traffic** (plain text)
- No authentication
- Use only on **trusted networks**

**Recommendations:**
```bash
# Restrict access via firewall
sudo ufw allow from 192.168.1.0/24 to any port 5000

# Close port after use
sudo ufw delete allow 5000
```


## 📄 License

MIT License - See [LICENSE](LICENSE)

---

## ⚖️ Disclaimer

Tool for **educational purposes** and **authorized testing**. Use only on your own networks or with explicit permission.

---

**Made with ☕ by [Rodrigo-Tripa](https://github.com/Rodrigo-Tripa)**
