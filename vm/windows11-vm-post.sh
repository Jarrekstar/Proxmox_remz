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
  send_keys_to_vm "$1"
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

function open_admin_ps() {
  open_run
  send_keys_to_vm "powershell"
  qm sendkey $VMID "ctrl-shift-ret"
  qm sendkey $VMID "left"
  qm sendkey $VMID "ret"
}

function close_window() {
  qm sendkey $VMID "alt-f4"
}


function send_keys_to_vm_quoted() {
  qm sendkey $VMID "apostrophe"
  qm sendkey $VMID "apostrophe"
  qm sendkey $VMID "backspace"
  send_keys_to_vm "$1"
  qm sendkey $VMID "apostrophe"
  qm sendkey $VMID "apostrophe"
  qm sendkey $VMID "backspace"
}

function send_keys_to_vm_doublequoted() {
  qm sendkey $VMID "shift-apostrophe"
  qm sendkey $VMID "shift-apostrophe"
  qm sendkey $VMID "backspace"
  send_keys_to_vm "$1"
  qm sendkey $VMID "shift-apostrophe"
  qm sendkey $VMID "shift-apostrophe"
  qm sendkey $VMID "backspace"
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
#send_line_to_vm "echo Installing virtio drivers and guest tools."
#send_line_to_vm "echo Command window will close automatically after installation."
#send_line_to_vm "E:/virtio-win-gt-x64.msi /qn ADDLOCAL=ALL"
send_line_to_vm "E:/virtio-win-guest-tools.exe /qn /s"
sleep 15
close_window

#Install TightVNC
open_admin_ps
#send_line_to_vm "echo ' Installing TightVNC server. Password: admin123' "
#send_line_to_vm "echo ' PowerShell window will close automatically after installation.' "


send_line_to_vm "Invoke-WebRequest -Uri https://raw.githubusercontent.com/remz1337/Proxmox/remz/misc/powershell/Install-TightVNC.ps1 -OutFile Install-TightVNC.ps1"
send_line_to_vm ".\Install-TightVNC.ps1"

#install winget first
#Install-PackageProvider NuGet -Force;
#Set-PSRepository PSGallery -InstallationPolicy Trusted
#Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle


#$progressPreference = 'silentlyContinue'
#Write-Information "Downloading WinGet and its dependencies..."
#Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
#Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
#Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
#Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
#Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
#Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

#send_keys_to_vm "$progressPreference = "
#send_keys_to_vm_quoted "silentlyContinue"
#qm sendkey $VMID "ret"
#send_keys_to_vm "Write-Information "
#send_keys_to_vm_doublequoted "Downloading WinGet and its dependencies..."
#qm sendkey $VMID "ret"
#send_line_to_vm "Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
#send_line_to_vm "Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx"
#send_line_to_vm "Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx"
#send_line_to_vm "Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx"
#send_line_to_vm "Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx"
#send_line_to_vm "Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"


#Install-Module -Name Microsoft.WinGet.Client

#Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
#Add-AppxPackage winget.msixbundle
#del winget.msixbundle
#send_line_to_vm "winget install -e --id GlavSoft.TightVNC --accept-source-agreements --accept-package-agreements --custom ' /quiet ADDLOCAL=Server SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=admin123' "
#winget install -e --id GlavSoft.TightVNC --accept-source-agreements --accept-package-agreements --custom "/quiet SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=mainpass"
#msiexec /i tightvnc-2.5.2-setup-64bit.msi /quiet /norestart ADDLOCAL=Server
#msiexec.exe /i tightvnc-2.5.2-setup-64bit.msi /quiet /norestart SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=mainpass
sleep 15
close_window