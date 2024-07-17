#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/remz1337/Proxmox/remz/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
# License: MIT
# https://github.com/remz1337/Proxmox/raw/main/LICENSE

function header_info {
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
header_info
echo -e "Loading..."
APP="Scrutiny"
var_disk="4"
var_cpu="2"
var_ram="512"
var_os="debian"
var_version="11"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
  if [[ ! -f /etc/systemd/system/scrutiny.service ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Stopping Scrutiny"
  systemctl stop scrutiny.service
  msg_ok "Stopped Scrutiny"

  msg_info "Updating Scrutiny"
  cd /opt/scrutiny/bin
  rm -rf scrutiny-web-linux-amd64
  wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-web-linux-amd64"
  chmod +x scrutiny-web-linux-amd64

  cd /opt/scrutiny/web
  rm -rf /opt/scrutiny/web/*
  wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-web-frontend.tar.gz"
  tar xvzf scrutiny-web-frontend.tar.gz --strip-components 1 -C .
  msg_ok "Updated Scrutiny"

  msg_info "Starting Scrutiny"
  systemctl start scrutiny.service
  msg_ok "Started Scrutiny"
}

start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -memory 256
pct set $CTID -cores 1
msg_ok "Set Container to Normal Resources"
msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8080${CL} \n"