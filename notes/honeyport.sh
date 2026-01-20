#!/bin/bash

PATH=/bin:/usr/bin:/sbin:/usr/sbin;export PATH
HONEYPORT=8080

function verify_running_as_root() {
  local rtr_code=''
  if [ $(id -u) -ne 0 ]; then
    rtr_code=0
  else
    rtr_code=-1
  fi
  echo ${rtr_code}
  exit ${rtr_code}
}

function honeyport_cmd() {
  local IP=''
  while [ 1 = 1 ]; do
    IP=$(nc -nvl ${HONEYPORT} 2>&1 1>/dev/null | grep -P '\s*Connection\s+from\s+.*\s+received' |awk -F'from ' '{print $2}'|awk '{print $1}')
    if [ ${IP} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]; then
      echo "Blocking IP: ${IP}"
      iptables -A INPUT -p tcp -s ${IP} -j DROP
    else
      echo "INVALID IP FORMAT: ${IP}"
    fi
  done
}

function main() {
  if [ $(verify_running_as_root) -eq 0 ]; then
    honeyport_cmd
  else
    echo "Running as a non-root user"
  fi
}

main
