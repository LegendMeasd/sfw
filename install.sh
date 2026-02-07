#!/bin/bash

# Surfshark WireGuard Installer
# Save this as: install.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="surfshark"
SHORT_NAME="sfw"
CONFIG_FILE="/etc/wireguard/surfshark.conf"

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════╗
║  Surfshark WireGuard Manager Installer       ║
║  Easy VPS VPN Management                     ║
╚═══════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use: sudo bash install.sh)${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting installation...${NC}\n"

# Step 1: Install WireGuard
echo -e "${YELLOW}[1/4] Installing WireGuard...${NC}"
apt update -qq
apt install -y wireguard iptables resolvconf curl > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ WireGuard installed${NC}"
else
    echo -e "${RED}✗ Failed to install WireGuard${NC}"
    exit 1
fi

# Step 2: Create the manager script
echo -e "${YELLOW}[2/4] Creating Surfshark manager script...${NC}"

cat > /tmp/surfshark-manager.sh << 'MAINSCRIPT'
#!/bin/bash

# Surfshark WireGuard Manager for VPS
CONFIG_FILE="/etc/wireguard/surfshark.conf"
INTERFACE="surfshark"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use: sudo surfshark or sudo sfw)${NC}"
    exit 1
fi

# Function to create configuration
create_config() {
    echo -e "${YELLOW}Creating Surfshark WireGuard configuration...${NC}"
    
    # Get the main network interface
    MAIN_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    cat > $CONFIG_FILE << 'EOF'
[Interface]
Address = 10.14.0.2/32
PrivateKey = +IRCcD4jEd4m/4REXT4U4nvzNqVTAy1u24OOGoj93H4=
DNS = 162.252.172.57, 149.154.159.92
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o MAIN_INTERFACE -j MASQUERADE; iptables -A FORWARD -o %i -j ACCEPT
PreDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o MAIN_INTERFACE -j MASQUERADE; iptables -D FORWARD -o %i -j ACCEPT

[Peer]
PublicKey = +8TxSpyyEGiZK6d/5V+94Zc7nxOV3F1ag7sM6AN86GY=
AllowedIPs = 0.0.0.0/0
Endpoint = lk-cmb.prod.surfshark.com:51820
PersistentKeepalive = 25
EOF

    sed -i "s/MAIN_INTERFACE/$MAIN_INTERFACE/g" $CONFIG_FILE
    
    # Enable IP forwarding
    if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    fi
    sysctl -p > /dev/null 2>&1
    
    chmod 600 $CONFIG_FILE
    echo -e "${GREEN}✓ Configuration created${NC}"
}

# Function to start WireGuard
start_wireguard() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}Configuration not found. Creating...${NC}"
        create_config
    fi
    
    if wg show $INTERFACE > /dev/null 2>&1; then
        echo -e "${YELLOW}Surfshark is already running!${NC}"
        show_status
    else
        echo -e "${YELLOW}Starting Surfshark VPN...${NC}"
        wg-quick up $INTERFACE
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Surfshark VPN started successfully!${NC}"
            sleep 1
            show_status
        else
            echo -e "${RED}✗ Failed to start${NC}"
        fi
    fi
}

# Function to stop WireGuard
stop_wireguard() {
    if wg show $INTERFACE > /dev/null 2>&1; then
        echo -e "${YELLOW}Stopping Surfshark VPN...${NC}"
        wg-quick down $INTERFACE
        echo -e "${GREEN}✓ Surfshark VPN stopped${NC}"
    else
        echo -e "${YELLOW}Surfshark is not running${NC}"
    fi
}

# Function to restart WireGuard
restart_wireguard() {
    echo -e "${YELLOW}Restarting Surfshark VPN...${NC}"
    stop_wireguard
    sleep 2
    start_wireguard
}

# Function to show status
show_status() {
    echo -e "\n${BLUE}╔═══════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Surfshark VPN Status          ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════╝${NC}\n"
    
    if wg show $INTERFACE > /dev/null 2>&1; then
        echo -e "${GREEN}Status: ● ACTIVE${NC}\n"
        wg show $INTERFACE
        echo ""
        echo -e "${YELLOW}Current Public IP:${NC}"
        CURRENT_IP=$(timeout 5 curl -s ifconfig.me 2>/dev/null || echo "Unable to fetch")
        echo -e "${GREEN}$CURRENT_IP${NC}"
    else
        echo -e "${RED}Status: ○ INACTIVE${NC}"
        echo -e "${YELLOW}VPN is not running${NC}"
    fi
    echo ""
}

# Function to enable auto-start
enable_autostart() {
    systemctl enable wg-quick@$INTERFACE 2>/dev/null
    echo -e "${GREEN}✓ Auto-start enabled${NC}"
}

# Function to disable auto-start
disable_autostart() {
    systemctl disable wg-quick@$INTERFACE 2>/dev/null
    echo -e "${GREEN}✓ Auto-start disabled${NC}"
}

# Function to check IP
check_ip() {
    echo -e "${YELLOW}Checking IP address...${NC}\n"
    CURRENT_IP=$(timeout 5 curl -s ifconfig.me 2>/dev/null || echo "Unable to fetch IP")
    echo -e "${GREEN}Current IP: $CURRENT_IP${NC}"
    
    if wg show $INTERFACE > /dev/null 2>&1; then
        echo -e "${GREEN}VPN Status: Active ✓${NC}"
    else
        echo -e "${YELLOW}VPN Status: Inactive${NC}"
    fi
}

# Uninstall function
uninstall() {
    echo -e "${RED}╔═══════════════════════════════════╗${NC}"
    echo -e "${RED}║     Uninstall Surfshark VPN       ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════╝${NC}\n"
    
    read -p "Are you sure you want to uninstall? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Uninstall cancelled${NC}"
        return
    fi
    
    echo -e "${YELLOW}Stopping VPN...${NC}"
    wg-quick down $INTERFACE 2>/dev/null
    
    echo -e "${YELLOW}Disabling auto-start...${NC}"
    systemctl disable wg-quick@$INTERFACE 2>/dev/null
    
    echo -e "${YELLOW}Removing configuration...${NC}"
    rm -f $CONFIG_FILE
    
    echo -e "${YELLOW}Removing scripts...${NC}"
    rm -f /usr/local/bin/surfshark
    rm -f /usr/local/bin/sfw
    
    echo -e "${GREEN}✓ Uninstallation complete!${NC}"
    echo -e "${YELLOW}WireGuard package is still installed. Remove with: apt remove wireguard${NC}"
    
    read -p "Remove WireGuard package too? (yes/no): " remove_wg
    if [ "$remove_wg" = "yes" ]; then
        apt remove -y wireguard
        apt autoremove -y
        echo -e "${GREEN}✓ WireGuard removed${NC}"
    fi
    
    exit 0
}

# Main menu
show_menu() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Surfshark WireGuard Manager         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"
    echo "  1) Start Surfshark VPN"
    echo "  2) Stop Surfshark VPN"
    echo "  3) Restart Surfshark VPN"
    echo "  4) Show Status"
    echo "  5) Check IP Address"
    echo "  6) Enable Auto-start on Boot"
    echo "  7) Disable Auto-start"
    echo "  8) Reconfigure VPN"
    echo "  9) Uninstall"
    echo "  0) Exit"
    echo ""
}

# Main logic
case "$1" in
    start)
        start_wireguard
        ;;
    stop)
        stop_wireguard
        ;;
    restart)
        restart_wireguard
        ;;
    status)
        show_status
        ;;
    enable)
        enable_autostart
        ;;
    disable)
        disable_autostart
        ;;
    ip)
        check_ip
        ;;
    setup|config)
        create_config
        ;;
    uninstall)
        uninstall
        ;;
    *)
        while true; do
            show_menu
            read -p "Select option [0-9]: " choice
            case $choice in
                1)
                    start_wireguard
                    ;;
                2)
                    stop_wireguard
                    ;;
                3)
                    restart_wireguard
                    ;;
                4)
                    show_status
                    ;;
                5)
                    check_ip
                    ;;
                6)
                    enable_autostart
                    ;;
                7)
                    disable_autostart
                    ;;
                8)
                    create_config
                    ;;
                9)
                    uninstall
                    exit 0
                    ;;
                0)
                    echo -e "${GREEN}Goodbye!${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Invalid option!${NC}"
                    ;;
            esac
            read -p "Press Enter to continue..."
            clear
        done
        ;;
esac
MAINSCRIPT

# Step 3: Install the script
echo -e "${YELLOW}[3/4] Installing scripts to system...${NC}"
chmod +x /tmp/surfshark-manager.sh

# Install with both names
cp /tmp/surfshark-manager.sh $INSTALL_DIR/$SCRIPT_NAME
cp /tmp/surfshark-manager.sh $INSTALL_DIR/$SHORT_NAME

chmod +x $INSTALL_DIR/$SCRIPT_NAME
chmod +x $INSTALL_DIR/$SHORT_NAME

echo -e "${GREEN}✓ Scripts installed:${NC}"
echo -e "  - ${YELLOW}$INSTALL_DIR/$SCRIPT_NAME${NC}"
echo -e "  - ${YELLOW}$INSTALL_DIR/$SHORT_NAME${NC}"

# Cleanup
rm -f /tmp/surfshark-manager.sh

# Step 4: Setup configuration
echo -e "${YELLOW}[4/4] Setting up configuration...${NC}"
$INSTALL_DIR/$SCRIPT_NAME setup
echo -e "${GREEN}✓ Configuration completed${NC}"

# Installation complete
echo -e "\n${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation Completed! ✓             ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}You can now use either command:${NC}\n"

echo -e "${YELLOW}Full command:${NC}"
echo -e "  ${GREEN}sudo surfshark${NC}          - Open menu"
echo -e "  ${GREEN}sudo surfshark start${NC}    - Start VPN"
echo -e "  ${GREEN}sudo surfshark stop${NC}     - Stop VPN"
echo -e "  ${GREEN}sudo surfshark status${NC}   - Check status"
echo -e "  ${GREEN}sudo surfshark uninstall${NC} - Uninstall"

echo -e "\n${YELLOW}Short command (same features):${NC}"
echo -e "  ${GREEN}sudo sfw${NC}                - Open menu"
echo -e "  ${GREEN}sudo sfw start${NC}          - Start VPN"
echo -e "  ${GREEN}sudo sfw stop${NC}           - Stop VPN"
echo -e "  ${GREEN}sudo sfw status${NC}         - Check status"
echo -e "  ${GREEN}sudo sfw uninstall${NC}      - Uninstall"

echo -e "\n${BLUE}Quick access: Just type '${GREEN}sudo sfw${BLUE}' anytime!${NC}\n"