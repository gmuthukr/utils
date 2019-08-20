#!/bin/bash

TUN_PORT=enp1s0
TUN_LOC_IP=192.168.216.147
TUN_REM_IP=192.168.216.145
VM_LOC_IP=10.0.0.147
VM_REM_IP=10.0.0.145

# be root
[[ `id -u` = "0" ]] || {
    echo "you are not root. be root to run again!"
    exit 1
}

# qemu kvm to be up and running on port vnet0
ifconfig vnet0 2>&1 1>/dev/null
[[ $? -eq 0 ]] || {
    echo "vnet0 port not up. bring up kvm manually!"
    exit 1
}

# no ovs processes should be up previously
pgrep ovsdb-server || pgrep ovs-vswitchd
[[ $? -eq 1 ]] || {
    echo "stop current ovs processes and run it again!"
    exit 1
}

# start ovs processes
rm -rf  /usr/local/etc/openvswitch/conf.db
rm -rf /usr/local/var/log/openvswitch/*
./ovsdb/ovsdb-tool create /usr/local/etc/openvswitch/conf.db ./vswitchd/vswitch.ovsschema
./ovsdb/ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --private-key=db:Open_vSwitch,SSL,private_key --certificate=Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --log-file=/usr/local/var/log/openvswitch/ovsdb-server.log --pidfile=/usr/local/var/run/openvswitch/ovsdb-server.pid --detach
./utilities/ovs-vsctl --no-wait init
./vswitchd/ovs-vswitchd unix:/usr/local/var/run/openvswitch/db.sock  --log-file=/usr/local/var/log/openvswitch/ovs-vswitchd.log --pidfile=/usr/local/var/run/openvswitch/ovs-vswitchd.pid --detach
sleep 3

# current ovs processes be up
pgrep ovsdb-server && pgrep ovs-vswitchd
[[ $? -eq 0 ]] || {
    echo "starting ovs processes not successful. check!"
    exit 1
}

# setup bridge and ports
./utilities/ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev && \
./utilities/ovs-vsctl add-port br0 vnet0 -- set interface vnet0 ofport_request=1 && \
./utilities/ovs-vsctl add-port br0 vxlan-1 -- set interface vxlan-1 type=vxlan options:remote_ip=$TUN_REM_IP ofport_req=100 && \
./utilities/ovs-vsctl add-br br1 -- set bridge br1 datapath_type=netdev && \
./utilities/ovs-vsctl add-port br1 $TUN_PORT -- set interface $TUN_PORT ofport_req=1 && \
ifconfig br1 ${TUN_LOC_IP}/24
[[ $? -eq 0 ]] || {
    echo "setting up bridge and ports fails. check!"
    exit 1
}

# update flowtable rules
./utilities/ovs-ofctl del-flows br0 && \
./utilities/ovs-ofctl add-flow br0 priority=5,ip,nw_dst=${VM_LOC_IP},action=output:1 && \
./utilities/ovs-ofctl add-flow br0 priority=5,ip,nw_dst=${VM_REM_IP},action=output:100 && \
./utilities/ovs-ofctl add-flow br0 priority=0,action=NORMAL && \
./utilities/ovs-ofctl del-flows br1 && \
./utilities/ovs-ofctl add-flow br1 priority=5,ip,in_port=LOCAL,action=output:1 && \
./utilities/ovs-ofctl add-flow br1 priority=5,ip,in_port=1,action=output:LOCAL && \
./utilities/ovs-ofctl add-flow br1 priority=0,action=NORMAL
[[ $? -eq 0 ]] || {
    echo "setting up flowtable rules fails. check!"
    exit 1
}

echo "OVS has been setup for your kvm on VxLAN overlay successfully ..."

echo "ovs-vsctl show"
./utilities/ovs-vsctl show
echo ""

echo "ovs-ofctl dump-ports-desc br0"
./utilities/ovs-ofctl dump-ports-desc br0
echo ""

echo "ovs-ofctl dump-ports-desc br1"
./utilities/ovs-ofctl dump-ports-desc br1
echo ""

echo "ovs-vsctl show"
./utilities/ovs-vsctl show
echo ""

echo "ovs-ofctl dump-flows br0"
./utilities/ovs-ofctl dump-flows br0
echo ""

echo "ovs-ofctl dump-flows br1"
./utilities/ovs-ofctl dump-flows br1
echo ""

echo "exitting script now .."

