#!/bin/bash

function install_iptables_addons() {

  if [ -e /usr/sbin/accept_forward ]
  then
    return
  fi

  SCRIPT=`realpath $0`
  SCRIPT_PATH=`dirname $SCRIPT`

  cp $SCRIPT_PATH/accept_forward /usr/sbin/accept_forward
  cp $SCRIPT_PATH/accept_forward /usr/sbin/delete_forward
  chmod +x /usr/sbin/accept_forward
  chmod +x /usr/sbin/delete_forward
}

function add_forward_knock() {

  install_iptables_addons

  KNOCK_NAME=$1
  OPEN_SEQUENCE=$2
  CLOSE_SEQUENCE=$3
  INPUT_INTERFACE=$4
  OUTPUT_INTERFACE=$5
  DESTINATION_IP=$6
  DESTINATION_PORT=$7
  
  COMMAND="/usr/sbin/accept_forward $INPUT_INTERFACE $OUTPUT_INTERFACE %IP% $DESTINATION_IP $DESTINATION_PORT"

  echo "[open_$KNOCK_NAME]
    sequence    = $OPEN_SEQUENCE
    seq_timeout = 10
    tcpflags    = syn
    command     = $COMMAND" >> /etc/knockd.conf
    
  COMMAND="/usr/sbin/delete_forward $INPUT_INTERFACE $OUTPUT_INTERFACE %IP% $DESTINATION_IP $DESTINATION_PORT"
    
  echo "[close_$KNOCK_NAME]
    sequence    = $CLOSE_SEQUENCE
    seq_timeout = 10
    tcpflags    = syn
    command     = $COMMAND" >> /etc/knockd.conf
}
    