#!/bin/bash

# ===============================
# UDPGW ONLY INSTALLER
# (ZIVPN SUDAH ADA)
# ===============================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

UDPGW_BIN="/usr/local/bin/udpgw"
UDPGW_CFG_DIR="/etc/udpgw"
TMP_DIR=$(mktemp -d)

set -e

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $1"; }

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_err "Jalankan sebagai root (sudo su)"
        exit 1
    fi
}

update_system() {
    log_info "Update system & dependency..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y git golang iptables-persistent netfilter-persistent
}

stop_udpgw() {
    log_info "Stop UDPGW service (jika ada)..."
    systemctl stop udpgw.service 2>/dev/null || true
}

build_udpgw() {
    log_info "Build UDPGW dari source..."
    cd "$TMP_DIR"

    git clone https://github.com/mukswilly/udpgw.git
    cd udpgw
    [ -d cmd ] && cd cmd

    export CGO_ENABLED=0
    go build -ldflags="-s -w" -o udpgw

    mv udpgw "$UDPGW_BIN"
    chmod +x "$UDPGW_BIN"

    log_info "UDPGW berhasil dibuild"
}

configure_udpgw() {
    log_info "Membuat config UDPGW..."
    mkdir -p "$UDPGW_CFG_DIR"

cat <<EOF > "$UDPGW_CFG_DIR/udpgw.json"
{
    "LogLevel": "info",
    "UdpgwPort": 7300,
    "DNSResolverIPAddress": "8.8.8.8"
}
EOF
}

configure_kernel() {
    log_info "Optimasi kernel UDP buffer..."
cat <<EOF > /etc/sysctl.d/udpgw.conf
net.core.rmem_max=16777216
net.core.wmem_max=16777216
EOF
    sysctl -p /etc/sysctl.d/udpgw.conf >/dev/null
}

setup_service() {
    log_info "Membuat service UDPGW..."
cat <<EOF > /etc/systemd/system/udpgw.service
[Unit]
Description=UDPGW Golang Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$UDPGW_CFG_DIR
ExecStart=$UDPGW_BIN run -config udpgw.json
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
}

setup_firewall() {
    log_info "Allow port UDPGW (7300)..."

    iptables -C INPUT -p udp --dport 7300 -j ACCEPT 2>/dev/null || \
    iptables -A INPUT -p udp --dport 7300 -j ACCEPT

    if command -v ufw >/dev/null; then
        ufw allow 7300/udp || true
    fi

    netfilter-persistent save >/dev/null 2>&1 || true
}

start_udpgw() {
    log_info "Start UDPGW service..."
    systemctl enable --now udpgw.service
}

# ===== MAIN =====
check_root
update_system
stop_udpgw
build_udpgw
configure_udpgw
configure_kernel
setup_service
setup_firewall
start_udpgw

echo ""
echo "======================================="
echo -e "${GREEN} UDPGW INSTALL SELESAI ${NC}"
echo "======================================="
echo " UDPGW Port : 7300"
echo " Config     : /etc/udpgw/udpgw.json"
echo " ZIVPN      : TIDAK DIUBAH"
echo "======================================="