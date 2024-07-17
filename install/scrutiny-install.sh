#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "Install Scrutiny" --yesno "This script will create a new LXC for the Scrutiny web app and install the Scrutiny collector on the host. Do you wish to continue?" 10 58); then
  echo -e "${DGN}Proceeding with Scrutiny installation${CL}"
else
  echo -e "${RD}Scrutiny installation aborted${CL}"
  exit-script
fi

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y {curl,sudo,mc,glibc}
msg_ok "Installed Dependencies"

msg_info "Installing Scrutiny (web app and API)"
mkdir -p /opt/scrutiny/config
mkdir -p /opt/scrutiny/web
mkdir -p /opt/scrutiny/bin

cd /opt/scrutiny/config
wget -O scrutiny.yaml https://raw.githubusercontent.com/AnalogJ/scrutiny/master/example.scrutiny.yaml

cd /opt/scrutiny/bin
wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-web-linux-amd64"
chmod +x scrutiny-web-linux-amd64

cd /opt/scrutiny/web
wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-web-frontend.tar.gz"

# Next, lets extract the frontend files.
# NOTE: after extraction, there **should not** be a `dist` subdirectory in `/opt/scrutiny/web` directory.
tar xvzf scrutiny-web-frontend.tar.gz --strip-components 1 -C .
msg_ok "Installed Scrutiny"


msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/scrutiny.service
[Unit]
Description=Scrutiny service
After=syslog.target network.target

[Service]
#SuccessExitStatus=143
#User=root
#Group=root

Type=simple

WorkingDirectory=/opt/scrutiny
ExecStart=/opt/scrutiny/bin/scrutiny-web-linux-amd64 start --config /opt/scrutiny/config/scrutiny.yaml

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now scrutiny
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf /opt/scrutiny/web/scrutiny-web-frontend.tar.gz
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

echo -e "Don't forget to ${GN}deploy the collector on the host${CL} and edit the Scrutiny config file (${GN}/opt/scrutiny/config/scrutiny.yaml${CL}) and reboot."