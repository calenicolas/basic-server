#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`

function create_chain() {
  NAME=$1
  
  iptables -N $NAME
  iptables -F $NAME
  iptables -X $NAME
  iptables -I $NAME -j RETURN
}

function load_input_filters() {
}

apt update
apt upgrade
apt install iptables-persistent knockd -y

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

iptables-save > /etc/iptables/rules.v4

cp $SCRIPT_PATH/port-knocing/pk_accept_forward /usr/local/sbin
cp $SCRIPT_PATH/port-knocing/pk_delete_forward /usr/local/sbin
cp $SCRIPT_PATH/port-knocing/knockd_configuration.sh /usr/local/lib