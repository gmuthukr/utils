#!/bin/bash

# be root
[[ `id -u` = "0" ]] || {
    echo "you are not root. be root to run again!"
    exit 1
}

# check if DPDK_DIR is set in env
[[ "$DPDK_DIR" = "" ]] && {
    echo "run setenv script and try again.!"
    exit 1
}

# check if mirror port is already created.
./utilities/ovs-vsctl list mirror mirror0 &>/dev/null
[[ $? -eq 1 ]] || {
    echo "mirror port already exists. you may run one of below:"
    echo "  ./utilities/ovs-vsctl list mirror mirror0       [to list]"
    echo "  ./utilities/ovs-vsctl clear bridge br1 mirrors  [to clear mirror(s)]"
    exit 1
}

# setup dummy port
ip link del dev pcap0 &>/dev/null
ip link add name pcap0 type dummy &&\
ip link set dev pcap0 up
[[ $? -eq 0 ]] || {
    echo "unable to create dummy port pcap0. check!"
    exit 1
}

# create mirror port
./utilities/ovs-vsctl del-port br1 pcap0 &>/dev/null
./utilities/ovs-vsctl add-port br1 pcap0 &&\
./utilities/ovs-vsctl -- set bridge br1 mirrors=@m -- --id=@pcap0 get port pcap0 -- --id=@dpdk0 get port dpdk0 -- --id=@m create mirror name=mirror0 select-dst-port=@dpdk0 select-src-port=@dpdk0 output-port=@pcap0 select_all=1 &&\
./utilities/ovs-vsctl list mirror 
[[ $? -eq 0 ]] || {
    echo "unable to mirror port pcap0 in ovs. check!"
    exit 1
}

