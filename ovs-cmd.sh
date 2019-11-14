#!/bin/bash

ovs-vsctl del-port ovsbr0 ens10
ovs-vsctl -- --all destroy QoS -- --all destroy QoS
ovs-vsctl -- --all destroy Queue -- --all destroy Queue
ovs-vsctl add-port ovsbr0 ens10

ovs-vsctl -- \
set port ens10 qos=@newqos -- \
  --id=@newqos create qos type=linux-htb \
      other-config:max-rate=10000000000 \
      queues:400=@q400m \
      queues:900=@q990m -- \
  --id=@q400m create queue other-config:max-rate=340000000 -- \
  --id=@q990m create queue other-config:max-rate=990000000

ovs-vsctl -- --columns=name,ofport list Interface

tc class change dev ens10 parent 1:fffe classid 1:385 htb prio 0 rate 12Kbit ceil 990Mbit burst 10000b cburst 1000000b
tc class change dev ens10 parent 1:fffe classid 1:191 htb prio 0 rate 12Kbit ceil 340Mbit burst 10000b cburst 1000000b
#ovs-ofctl add-flow ovsbr0 ip,nw_dst=149.165.232.118,in_port=1,actions=set_queue:400,normal

