#!/bin/bash

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

echo "please install knockd"

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

create_chain FORWARD_PORT_KNOCKING
create_chain INPUT_FILTERS

load_input_filters

iptables -I FORWARD -j FORWARD_PORT_KNOCKING
iptables -I INPUT -j INPUT_FILTERS

cp ./port-knocing/pk_accept_forward /usr/local/sbin
cp ./port-knocing/pk_delete_forward /usr/local/sbin