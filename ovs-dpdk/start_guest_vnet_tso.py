#!/usr/bin/python
import os
import subprocess
try:
        subprocess.check_output("qemu-system-x86_64 -enable-kvm -name rhel7.1_2 -m 1024 -smp 4,sockets=4,cores=1,threads=1 -drive file=/var/lib/libvirt/images/f25ce590-930d-4ebf-bd8d-97f0d153773-0.img,if=none,id=drive-virtio-disk0,format=qcow2,cache=none -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x7,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 -netdev tap,id=hostnet1,script=no,downscript=no,ifname=vnet1 -device virtio-net-pci,netdev=hostnet1,mac=00:00:00:00:01:30,id=net1 -vnc :1 ", stderr=subprocess.STDOUT,shell=True)
except subprocess.CalledProcessError as e:
        print e.output
