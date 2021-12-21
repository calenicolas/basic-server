#!/bin/bash

function add_forward_knock() {

  KNOCK_NAME=$1
  SEQUENCE=$2
  INPUT_INTERFACE=$3
  OUTPUT_INTERFACE=$4
  DESTINATION_IP=$5
  DESTINATION_PORT=$6
  
  COMMAND="/usr/sbin/iptables -I FORWARD_PORT_KNOCKING \
  -i $INPUT_INTERFACE \
  -o $OUTPUT_INTERFACE \
  -s %IP% \
  -d $DESTINATION \
  --dport $DESTINATION_PORT \
  -m STATE \
  --state NEW,ESTABLISHED \
  -j ACCEPT"

  echo "[$KNOCK_NAME]
    sequence    = $SEQUENCE
    seq_timeout = 10
    tcpflags    = syn
    command     = $COMMAND" >> /etc/knockd.conf
}
[options]
    logfile = /var/log/knockd.log
[openSSH]
    sequence    = 7000,8000,9000
    seq_timeout = 10
    tcpflags    = syn
    command     = /usr/sbin/iptables -I INPUT -s %IP% -j ACCEPT
[closeSSH]
    sequence    = 9000,8000,7000
    seq_timeout = 10
    tcpflags    = syn
    command     = /usr/sbin/iptables -D INPUT -s %IP% -j ACCEPT
    
    