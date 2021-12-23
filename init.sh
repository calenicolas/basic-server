#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`

function create_chain() {
  NAME=$1
  
  iptables -N $NAME
  iptables -F $NAME
  iptables -I $NAME -j RETURN
}

function load_input_filters() {
  echo "TODO"
}

apt update
apt upgrade

echo "Ingrese la interfaz donde escucha actualmente el servicio de ssh"
read SSH_INTERFACE

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

create_chain FORWARD_PORT_KNOCKING
create_chain INPUT_FILTERS

load_input_filters

iptables -I FORWARD -j FORWARD_PORT_KNOCKING
iptables -I INPUT -j INPUT_FILTERS

SSH_CLIENT=$(echo $SSH_CLIENT | awk '{ print $1}')

iptables -A INPUT -i $SSH_INTERFACE -p tcp --dport 22 -m state --state NEW,ESTABLISHED -s $SSH_CLIENT -j  ACCEPT
iptables -A OUTPUT -o $SSH_INTERFACE -p tcp --sport 22 -m state --state ESTABLISHED -d $SSH_CLIENT -j  ACCEPT

apt install iptables-persistent knockd -y

cp $SCRIPT_PATH/port-knocking/lib/knockd_configuration.sh /usr/local/lib

chmod +x $SCRIPT_PATH/port-knocking/*

cp $SCRIPT_PATH/port-knocking/bin/pk_accept_forwarding /usr/local/sbin
cp $SCRIPT_PATH/port-knocking/bin/pk_delete_forwarding /usr/local/sbin
cp $SCRIPT_PATH/port-knocking/bin/pk_protect_forwarding /usr/local/sbin
