#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: remz1337
# Co-Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
 _       ___           __                      ______   _    ____  ___
| |     / (_)___  ____/ /___ _      _______   <  <  /  | |  / /  |/  /
| | /| / / / __ \/ __  / __ \ | /| / / ___/   / // /   | | / / /|_/ / 
| |/ |/ / / / / / /_/ / /_/ / |/ |/ (__  )   / // /    | |/ / /  / /  
|__/|__/_/_/ /_/\__,_/\____/|__/|__/____/   /_//_/     |___/_/  /_/   

EOF
}
header_info

function send_keys_to_vm() {
  echo -e "${DGN}Sending line: ${YW}$1${CL}"
  for ((i = 0; i < ${#1}; i++)); do
    character=${1:i:1}
    case $character in
    " ") character="spc" ;;
    "-") character="minus" ;;
    "=") character="equal" ;;
    ",") character="comma" ;;
    ".") character="dot" ;;
    "/") character="slash" ;;
    "'") character="apostrophe" ;;
    ";") character="semicolon" ;;
    '\') character="backslash" ;;
    '`') character="grave_accent" ;;
    "[") character="bracket_left" ;;
    "]") character="bracket_right" ;;
    "_") character="shift-minus" ;;
    "+") character="shift-equal" ;;
    "?") character="shift-slash" ;;
    "<") character="shift-comma" ;;
    ">") character="shift-dot" ;;
    '"') character="shift-apostrophe" ;;
    ":") character="shift-semicolon" ;;
    "|") character="shift-backslash" ;;
    "~") character="shift-grave_accent" ;;
    "{") character="shift-bracket_left" ;;
    "}") character="shift-bracket_right" ;;
    "A") character="shift-a" ;;
    "B") character="shift-b" ;;
    "C") character="shift-c" ;;
    "D") character="shift-d" ;;
    "E") character="shift-e" ;;
    "F") character="shift-f" ;;
    "G") character="shift-g" ;;
    "H") character="shift-h" ;;
    "I") character="shift-i" ;;
    "J") character="shift-j" ;;
    "K") character="shift-k" ;;
    "L") character="shift-l" ;;
    "M") character="shift-m" ;;
    "N") character="shift-n" ;;
    "O") character="shift-o" ;;
    "P") character="shift-p" ;;
    "Q") character="shift-q" ;;
    "R") character="shift-r" ;;
    "S") character="shift-s" ;;
    "T") character="shift-t" ;;
    "U") character="shift-u" ;;
    "V") character="shift-v" ;;
    "W") character="shift-w" ;;
    "X") character="shift=x" ;;
    "Y") character="shift-y" ;;
    "Z") character="shift-z" ;;
    "!") character="shift-1" ;;
    "@") character="shift-2" ;;
    "#") character="shift-3" ;;
    '$') character="shift-4" ;;
    "%") character="shift-5" ;;
    "^") character="shift-6" ;;
    "&") character="shift-7" ;;
    "*") character="shift-8" ;;
    "(") character="shift-9" ;;
    ")") character="shift-0" ;;
    esac
    qm sendkey $VMID "$character"
  done
}


function send_line_to_vm() {
  send_keys_to_vm $1
  qm sendkey $VMID ret
}

function open_run() {
  qm sendkey $VMID "meta_l-r"
}

function open_admin_cmd() {
  open_run
  send_keys_to_vm "cmd"
  qm sendkey $VMID "ctrl-shift-ret"
  qm sendkey $VMID "left"
  qm sendkey $VMID "ret"
}

while true; do
  if VMID=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Virtual Machine ID" 8 58 100 --title "VIRTUAL MACHINE ID" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z "$VMID" ]; then
      VMID="100"
    fi
    if qm status "$VMID" &>/dev/null; then
      echo -e "${DGN}Virtual Machine ID: ${BGN}$VMID${CL}"
	  break
	else
	  echo -e "${CROSS}${RD} ID $VMID is not a valid VM${CL}"
    fi
  else
    exit
  fi
done

open_admin_cmd
#send_line_to_vm "E:/virtio-win-gt-x64.msi /qn ADDLOCAL=ALL"
send_line_to_vm "E:/virtio-win-guest-tools.exe /qn /s"