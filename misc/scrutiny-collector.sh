#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
# License: MIT
# https://github.com/remz1337/Proxmox/raw/main/LICENSE

header_info() {
  clear
  cat <<"EOF"
   _____                 __  _            
  / ___/____________  __/ /_(_)___  __  __
  \__ \/ ___/ ___/ / / / __/ / __ \/ / / /
 ___/ / /__/ /  / /_/ / /_/ / / / / /_/ / 
/____/\___/_/   \__,_/\__/_/_/ /_/\__, /  
                                 /____/   

EOF
}

RD=$(echo "\033[01;31m")
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

set -euo pipefail
shopt -s inherit_errexit nullglob

msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

start_routines() {
  header_info
  if [[ ! -f /etc/systemd/system/scrutiny.service ]]; then
    #Not found, install
	msg_info "Installing Scrutiny Collector"
    apt-get install -y smartmontools
    mkdir -p /opt/scrutiny/bin
    mkdir -p /opt/scrutiny/config
  
    cd /opt/scrutiny/config
    wget -O collector.yaml https://raw.githubusercontent.com/AnalogJ/scrutiny/master/example.collector.yaml
    # #Enable API endpoint
    # cat <<EOF >>/opt/scrutiny/config/collector.yaml
# api:
  # endpoint: 'http://${IP}:8080'
# EOF

    cd /opt/scrutiny/bin
    wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-collector-metrics-linux-amd64"
    chmod +x scrutiny-collector-metrics-linux-amd64

    cat <<EOF >/etc/systemd/system/scrutiny.service
[Unit]
Description="Scrutiny Collector service"
Requires=scrutiny.timer
After=syslog.target network.target

[Service]
Type=simple
WorkingDirectory=/opt/scrutiny
ExecStart=/opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 run --config /opt/scrutiny/config/collector.yaml
EOF

    cat <<EOF >/etc/systemd/system/scrutiny.timer
[Unit]
Description="Timer for the scrutiny.service"

[Timer]
Unit=scrutiny.service
OnCalendar=*:0/15

[Install]
WantedBy=timers.target
EOF

    systemctl enable -q --now scrutiny.timer
	msg_ok "Installed Scrutiny Collector"
	msg_ok "Don't forget to update the the configuration in ${GN}/opt/scrutiny/config/collector.yaml${CL}"
  else
    #Already installed, update
	msg_ok "Scrutiny Collector already installed. It will be updated."
    msg_info "Stopping Scrutiny Collector"
    systemctl disable --now scrutiny.timer
    msg_ok "Stopped Scrutiny Collector"

    msg_info "Updating Scrutiny Collector"
    cd /opt/scrutiny/bin
    rm -rf scrutiny-collector-metrics-linux-amd64
    wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-collector-metrics-linux-amd64"
    chmod +x scrutiny-collector-metrics-linux-amd64
    msg_ok "Updated Scrutiny Collector"

    msg_info "Starting Scrutiny Collector"
    systemctl enable -q --now scrutiny.timer
    msg_ok "Started Scrutiny Collector"
  fi
}

header_info
echo -e "\nThis script will install Scrutiny Collector service.\n"
while true; do
  read -p "Start the Scrutiny Collector Install Script (y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) clear; exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

start_routines
