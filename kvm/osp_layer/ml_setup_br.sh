#!/bin/bash
VHPATH=/var/lib/vhost_sockets
VM1P1=100
VM1P2=101
VM1IP61=fe80::f816:3eff:fe93:fccf
VM1IP62=fe80::f816:3eff:fedf:3f1f
VM1IP1=10.10.10.10
VM1IP2=20.20.20.20
VM1P1M=52:54:00:71:a0:01
VM1P2M=52:54:00:71:a0:02
HOP1=10
HOP2=11
NQ=1

USAGE='USAGE: ml_setup_br.sh <n_q> \n
                 n_q: number of rx/tx queues\n
                 -b: with ovs bonding (optional)'

if [[ $1 -ge 1 ]]
then
	NQ=$1
else
	echo -e $USAGE
	exit 1
fi

if [[ "$2" = "-b" ]]
then
	OBND=1
fi

#cleanup
sudo ovs-vsctl del-port br-int dpdkvhostclient0
sudo ovs-vsctl del-port br-int dpdkvhostclient1
ovs-vsctl del-port br-link0 dpdk0
ovs-vsctl del-port br-link0 dpdk1
ovs-vsctl del-port br-link0 dpdkbond0
ovs-vsctl del-br br-int
ovs-vsctl del-br br-link0

# create bridges
ovs-vsctl add-br br-int -- set bridge br-int datapath_type=netdev
ovs-vsctl add-br br-link0 -- set bridge br-link0 datapath_type=netdev

#add ports
ovs-vsctl add-port br-int dpdkvhostclient0 -- set Interface dpdkvhostclient0 type=dpdkvhostuserclient options:vhost-server-path=$VHPATH/dpdkvhostclient0 options:n_rxq=1 options:n_txq=1 ofport_request=100
ovs-vsctl add-port br-int dpdkvhostclient1 -- set Interface dpdkvhostclient1 type=dpdkvhostuserclient options:vhost-server-path=$VHPATH/dpdkvhostclient1 options:n_rxq=1 options:n_txq=1 ofport_request=101
ovs-vsctl add-port br-int int-br-link0 -- set interface int-br-link0 type=patch -- set interface int-br-link0 options:peer=link0-br-int ofport_request=500

if [[ $OBND -eq 1 ]]
then
	ovs-vsctl add-bond br-link0 dpdkbond0 dpdk0 dpdk1 -- set interface dpdk0 type=dpdk options:dpdk-devargs=0000:19:00.0 options:n_rxq=$NQ options:n_txq=$NQ options:n_rxq_desc=4096 options:n_txq_desc=4096 ofport_request=10 -- set interface dpdk1 type=dpdk options:dpdk-devargs=0000:19:00.1 options:n_rxq=$NQ options:n_txq=$NQ options:n_rxq_desc=4096 options:n_txq_desc=4096 ofport_request=11
else
	ovs-vsctl add-port br-link0 dpdk0 -- set interface dpdk0 type=dpdk options:dpdk-devargs=0000:19:00.0 options:n_rxq=1 options:n_txq=1 options:n_rxq_desc=4096 options:n_txq_desc=4096 ofport_request=10
	ovs-vsctl add-port br-link0 dpdk1 -- set interface dpdk1 type=dpdk options:dpdk-devargs=0000:19:00.1 options:n_rxq=1 options:n_txq=1 options:n_rxq_desc=4096 options:n_txq_desc=4096 ofport_request=11
fi

ovs-vsctl add-port br-link0 link0-br-int -- set interface link0-br-int type=patch -- set interface link0-br-int options:peer=int-br-link0 ofport_request=510

#add flows
ovs-ofctl del-flows br-int
ovs-ofctl del-flows br-link0

ovs-ofctl add-flow br-int "table=0,priority=10,icmp6,in_port=$VM1P1,icmp_type=136,actions=resubmit(,24)"
ovs-ofctl add-flow br-int "table=0,priority=10,icmp6,in_port=$VM1P2,icmp_type=136,actions=resubmit(,24)"
ovs-ofctl add-flow br-int "table=0,priority=10,arp,in_port=$VM1P1,actions=resubmit(,24)"
ovs-ofctl add-flow br-int "table=0,priority=10,arp,in_port=$VM1P2,actions=resubmit(,24)"
ovs-ofctl add-flow br-int "table=0,priority=9,in_port=$VM1P1,actions=resubmit(,25)"
ovs-ofctl add-flow br-int "table=0,priority=9,in_port=$VM1P2,actions=resubmit(,25)"
ovs-ofctl add-flow br-int "table=0,priority=3,in_port=500,dl_vlan=801,actions=mod_vlan_vid:1,NORMAL"
ovs-ofctl add-flow br-int "table=0,priority=2,in_port=500,actions=drop"
ovs-ofctl add-flow br-int "table=0,priority=0,actions=NORMAL"
ovs-ofctl add-flow br-int "table=23,priority=0,actions=drop"
ovs-ofctl add-flow br-int "table=24,priority=2,icmp6,in_port=$VM1P1,icmp_type=136,nd_target=$VM1IP61,actions=NORMAL"
ovs-ofctl add-flow br-int "table=24,priority=2,icmp6,in_port=$VM1P1,icmp_type=136,nd_target=$VM1IP62,actions=NORMAL"
ovs-ofctl add-flow br-int "table=24,priority=2,arp,in_port=$VM1P1,arp_spa=$VM1IP1,actions=resubmit(,25)"
ovs-ofctl add-flow br-int "table=24,priority=2,arp,in_port=$VM1P2,arp_spa=$VM1IP2,actions=resubmit(,25)"
ovs-ofctl add-flow br-int "table=24,priority=0,actions=drop"
ovs-ofctl add-flow br-int "table=25,priority=2,in_port=$VM1P1,dl_src=$VM1P1M,actions=NORMAL"
ovs-ofctl add-flow br-int "table=25,priority=2,in_port=$VM1P2,dl_src=$VM1P2M,actions=NORMAL"

ovs-ofctl add-flow br-link0 "table=0,priority=4,in_port=510,dl_vlan=1,actions=mod_vlan_vid:801,NORMAL"
ovs-ofctl add-flow br-link0 "table=0,priority=2,in_port=510,actions=drop"
ovs-ofctl add-flow br-link0 "table=0,priority=0,actions=NORMAL"

#update pmd affinity
ovs-vsctl set Interface dpdkvhostclient0 other_config:pmd-rxq-affinity="0:16"
ovs-vsctl set Interface dpdkvhostclient1 other_config:pmd-rxq-affinity="0:40"
ovs-vsctl set Interface dpdk0 other_config:pmd-rxq-affinity="0:40"
ovs-vsctl set Interface dpdk1 other_config:pmd-rxq-affinity="0:16"

