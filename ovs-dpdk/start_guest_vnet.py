#!/usr/bin/python
import os
import subprocess
try:
        subprocess.check_output("qemu-system-ppc64 -machine accel=kvm -name gs-rhel6.6-perf -m 1024 -smp 4,sockets=4,cores=1,threads=1 -device pci-ohci,id=usb,bus=pci.0,addr=0x2 -device spapr-vscsi,id=scsi0,reg=0x2000 -drive file=/var/lib/libvirt/images/gowri/gs-rhel6.6.qcow2,if=none,id=drive-virtio-disk0,format=qcow2,cache=none -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x3,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1  -netdev tap,id=hostnet0,script=no,downscript=no,ifname=vnet0 -device virtio-net-pci,netdev=hostnet0,mac=00:00:00:00:01:47,id=net0,csum=off -vnc :0 ", stderr=subprocess.STDOUT,shell=True)
except subprocess.CalledProcessError as e:
        print e.output
