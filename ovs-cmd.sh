#!/bin/bash

#DEBUG="echo "

DEF_RATE=10000000000

ARGC=$#
CMD=$1
IFACE=$2
NAME=$3
RATE=$4

usage() {
    echo "$0 add|clear|show iface name rate"
    exit 1
}

if [ "$CMD" == "clear" ]; then
    [ $ARGC -lt 2 ] && usage

    $DEBUG ovs-vsctl -- destroy QoS $IFACE -- clear Port $IFACE qos
    $DEBUG ovs-vsctl -- --all destroy QoS -- --all destroy QoS
    $DEBUG ovs-vsctl -- --all destroy Queue -- --all destroy Queue
fi

if [ "$CMD" == "show" ]; then
    [ $ARGC -lt 2 ] && usage

    $DEBUG ovs-appctl qos/show $IFACE
fi

if [ "$CMD" == "add" ]; then
    [ $ARGC -lt 4 ] && usage
    
    $DEBUG ovs-vsctl -- \
	 set port $IFACE qos=@newqos -- \
	   --id=@newqos create qos type=linux-htb \
         other-config:max-rate=$DEF_RATE \
         queues:${NAME}=@q${NAME}m -- \
	   --id=@q${NAME}m create queue other-config:max-rate=${RATE}

    #$DEBUG ovs-vsctl -- --columns=name,ofport list Interface
    $DEBUG ovs-appctl qos/show $IFACE

    #tc class change dev $IFACE parent 1:fffe classid 1:385 htb prio 0 rate 12Kbit \
    #   ceil 990Mbit burst 10000b cburst 1000000b
    #ovs-ofctl add-flow ovsbr0 ip,nw_dst=149.165.232.118,in_port=1,actions=set_queue:400,normal
fi

[ $ARGC -lt 1 ] && usage
