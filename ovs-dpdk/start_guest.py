#!/usr/bin/python
import os
import subprocess
try:
        subprocess.check_output("qemu-system-ppc64 -machine accel=kvm -name gs-rhel7.2-le -m 1024 -smp 4,sockets=4,cores=1,threads=1 -device pci-ohci,id=usb,bus=pci.0,addr=0x2 -device spapr-vscsi,id=scsi0,reg=0x2000 -drive file=/var/lib/libvirt/images/gowri/gs-rhel.7.2.le.qcow2,if=none,id=drive-virtio-disk0,format=qcow2,cache=none -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x3,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 -chardev socket,id=char1,path=/usr/local/var/run/openvswitch/vhost-user-1 -netdev type=vhost-user,id=hostnet1,chardev=char1,vhostforce=on -device virtio-net-pci,netdev=hostnet1,mac=00:00:00:00:01:47,ioeventfd=on -vnc :0  -object memory-backend-file,id=mem,size=1024M,mem-path=/dev/hugepages,share=on -numa node,memdev=mem -mem-prealloc", stderr=subprocess.STDOUT,shell=True)
except subprocess.CalledProcessError as e:
        print e.output
