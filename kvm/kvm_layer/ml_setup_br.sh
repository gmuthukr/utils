#!/bin/bash
VHPATH=/var/lib/vhost_sockets
VM1P1=100
VM1P2=101
HOP1=10
HOP2=11
NQ=1
OBND=0

USAGE="USAGE: ml_setup_br.sh <n_q> [-b] \n
                 n_q: number of rx/tx queues\n
                 -b: with ovs bonding (optional)"

if [[ $1 -ge 1 ]]
then
	NQ=$1
else
	echo $USAGE
	exit 1
fi

if [[ "$2" = "-b" ]]
then
	OBND=1
fi

#cleanup
ovs-vsctl del-port br-int dpdkvhostclient0
ovs-vsctl del-port br-int dpdkvhostclient1
ovs-vsctl del-port br-link0 dpdk0
ovs-vsctl del-port br-link0 dpdk1
ovs-vsctl del-br br-int
ovs-vsctl del-br br-link0

# create bridges
ovs-vsctl add-br br-int -- set bridge br-int datapath_type=netdev

#add ports
ovs-vsctl add-port br-int dpdkvhostclient0 -- set Interface dpdkvhostclient0 type=dpdkvhostuserclient options:vhost-server-path=$VHPATH/dpdkvhostclient0 options:n_rxq=1 options:n_txq=1 ofport_request=$VM1P1
ovs-vsctl add-port br-int dpdkvhostclient1 -- set Interface dpdkvhostclient1 type=dpdkvhostuserclient options:vhost-server-path=$VHPATH/dpdkvhostclient1 options:n_rxq=1 options:n_txq=1 ofport_request=$VM1P2

if [[ $OBND -eq 1 ]]
	ovs-vsctl del-port br-int dpdkbond0
	ovs-vsctl add-bond br-int dpdkbond0 dpdk0 dpdk1 -- set interface dpdk0 type=dpdk options:dpdk-devargs=0000:19:00.0 options:n_rxq=1 options:n_txq=1 options:n_rxq_desc=4096 options:n_txq_desc=4096 ofport_request=$HOP1 -- set interface dpdk1 type=dpdk options:dpdk-devargs=0000:19:00.1 options:n_rxq=1 options:n_txq=1 options:n_rxq_desc=4096 options:n_txq_desc=4096 ofport_request=$HOP2
	ovs-vsctl set port dpdkbond0 bond_mode=balance-slb
then
	ovs-vsctl add-port br-int dpdk0 -- set interface dpdk0 type=dpdk options:dpdk-devargs=0000:19:00.0 options:n_rxq=1 options:n_txq=1 options:n_rxq_desc=4096 options:n_txq_desc=4096 ofport_request=$HOP1
	ovs-vsctl add-port br-int dpdk1 -- set interface dpdk1 type=dpdk options:dpdk-devargs=0000:19:00.1 options:n_rxq=1 options:n_txq=1 options:n_rxq_desc=4096 options:n_txq_desc=4096 ofport_request=$HOP2
fi

#add flows
ovs-ofctl del-flows br-int

ovs-ofctl add-flow br-int "in_port=$VM1P1,action=output:$HOP1"
ovs-ofctl add-flow br-int "in_port=$HOP1,action=output:$VM1P1"
ovs-ofctl add-flow br-int "in_port=$VM1P2,action=output:$HOP2"
ovs-ofctl add-flow br-int "in_port=$HOP2,action=output:$VM1P2"

#update pmd affinity
ovs-vsctl set Interface dpdkvhostclient0 other_config:pmd-rxq-affinity="0:16"
ovs-vsctl set Interface dpdkvhostclient1 other_config:pmd-rxq-affinity="0:40"
ovs-vsctl set Interface dpdk0 other_config:pmd-rxq-affinity="0:40"
ovs-vsctl set Interface dpdk1 other_config:pmd-rxq-affinity="0:16"

