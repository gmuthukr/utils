#!/bin/bash -x
echo "virsh list --all"
virsh list --all

virsh destroy undercloud-0
virsh destroy controller-0
virsh undefine undercloud-0
virsh undefine controller-0
rm -f /var/lib/libvirt/images/undercloud-0*
rm -f /var/lib/libvirt/images/controller-0*

echo "removed kvm guests"

echo "virsh list --all"
virsh list --all

echo "virsh net-list --all"
virsh net-list --all

virsh net-destroy br-ctlplane
virsh net-destroy br-link0
virsh net-destroy br-link1
virsh net-destroy management
virsh net-undefine br-ctlplane
virsh net-undefine br-link0
virsh net-undefine br-link1
virsh net-undefine management
ifconfig br-ctlplane down
ifconfig br-link0 down
ifconfig br-link1 down
ifconfig management down
brctl delbr br-ctlplane
brctl delbr br-link0
brctl delbr br-link1
brctl delbr management
rm -f /etc/sysconfig/network-scripts/ifcfg-br-ctlplane
rm -f /etc/sysconfig/network-scripts/ifcfg-br-link0
rm -f /etc/sysconfig/network-scripts/ifcfg-br-link1
echo "removed kvm networks"

echo "virsh net-list --all"
virsh net-list --all


