# 🚀 Surfshark WireGuard Manager

Easy-to-use WireGuard VPN manager for routing all VPS traffic through Surfshark. Perfect for 3x-ui, SSH scripts, and any applications on your VPS.

## ⚡ One-Line Installation
```bash
bash <(curl -Ls https://raw.githubusercontent.com/YOUR-USERNAME/surfshark-wireguard-manager/main/install.sh)
```

Or using wget:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/YOUR-USERNAME/surfshark-wireguard-manager/main/install.sh)
```

## 📖 Quick Usage

After installation, use the short command `sfw`:
```bash
sudo sfw                # Open interactive menu
sudo sfw start          # Start VPN
sudo sfw stop           # Stop VPN  
sudo sfw status         # Check VPN status
sudo sfw ip             # Check current IP
sudo sfw uninstall      # Remove everything
```

Or use the full command `surfshark` (works the same):
```bash
sudo surfshark          # Open interactive menu
sudo surfshark start    # Start VPN
sudo surfshark stop     # Stop VPN
```

## ✨ Features

- ✅ **Easy Installation** - One command setup
- ✅ **Routes All Traffic** - 3x-ui, SSH, and all VPS traffic through Surfshark
- ✅ **Simple Controls** - Start/stop with one command
- ✅ **Auto-Start Option** - Start VPN automatically on boot
- ✅ **IP Checking** - Verify your VPN connection
- ✅ **Clean Uninstall** - Remove everything with one command
- ✅ **Short Command** - Just type `sfw` for quick access

## 🎯 What This Does

When you start the VPN:
- All outgoing traffic from your VPS goes through Surfshark
- Your 3x-ui configs automatically use the VPN
- SSH scripts route through the VPN
- Your VPS IP appears as Surfshark's IP

Perfect for:
- Protecting 3x-ui panel traffic
- Running SSH scripts through VPN
- Masking your VPS's real IP
- Bypassing geo-restrictions

## 🔧 Requirements

- Ubuntu/Debian VPS (tested on Ubuntu 20.04, 22.04, 24.04)
- Root/sudo access
- Active Surfshark WireGuard subscription

## 📝 Configuration

The installer automatically sets up Surfshark WireGuard with:
- Interface: `surfshark` (wg0)
- Config location: `/etc/wireguard/surfshark.conf`
- Uses `/32` subnet (required for some setups)
- IP forwarding enabled
- DNS: Surfshark DNS servers

### Custom Configuration

If you need to update your Surfshark credentials:
```bash
sudo nano /etc/wireguard/surfshark.conf
```

Then restart:
```bash
sudo sfw restart
```

## 💡 Examples

**Basic Usage:**
```bash
# Install
bash <(curl -Ls https://raw.githubusercontent.com/YOUR-USERNAME/surfshark-wireguard-manager/main/install.sh)

# Start VPN
sudo sfw start

# Check if working
sudo sfw ip

# Stop VPN
sudo sfw stop
```

**Enable Auto-Start on Boot:**
```bash
sudo sfw
# Select option 6
```

**Check Connection Status:**
```bash
sudo sfw status
```

## 🗑️ Uninstall

Two ways to uninstall:

**Method 1: Using the command**
```bash
sudo sfw uninstall
```

**Method 2: Using the menu**
```bash
sudo sfw
# Select option 9
```

This will:
- Stop the VPN
- Remove all configurations
- Remove the scripts (`sfw` and `surfshark`)
- Optionally remove WireGuard package

## 🛠️ Troubleshooting

**VPN won't start?**
```bash
# Check WireGuard status
sudo wg show

# Check logs
sudo journalctl -u wg-quick@surfshark -n 50
```

**Can't connect after starting VPN?**
```bash
# Verify IP changed
sudo sfw ip

# Restart VPN
sudo sfw restart
```

**Need to reconfigure?**
```bash
sudo sfw
# Select option 8 (Reconfigure)
```

## 🔐 Security Notes

- Your Surfshark private key is stored in `/etc/wireguard/surfshark.conf` (600 permissions)
- Only root can read the configuration
- All traffic is encrypted through WireGuard tunnel
- DNS queries go through Surfshark DNS

## 📊 How It Works
```
Your VPS Apps (3x-ui, SSH, etc.)
            ↓
    WireGuard Tunnel
            ↓
    Surfshark Servers
            ↓
        Internet
```

## 🤝 Contributing

Feel free to open issues or submit pull requests!

## 📄 License

MIT License - feel free to use and modify!

## ⭐ Support

If this helped you, give it a star! ⭐

---

**Made with ❤️ for easy VPS VPN management**
```

### **3. `LICENSE` (Optional)**
```
MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.