#!/usr/bin/env python
import sys
import subprocess
import json

DUT = "wsfd-advnetlab5.ntdv.lab.eng.bos.redhat.com"

def exec_command(cmd):
    try:
        ret = subprocess.check_output(cmd.split())
    except subprocess.CalledProcessError, e:
        nlog.info("Unable to execute command %s: %s" %(cmd, e))
        return 1
    return ret

def dut_command(cmd):
    return exec_command("ssh %s %s" %(DUT, cmd))

def main():
    tx_pps = 1.537959

    for i in (50, 60, 70, 80, 90, 100):
        tx_i = (i*tx_pps)*100
        pb_cmd = "/root/trafficgen/trex-txrx.py --device-pairs=0:1 --active-device-pairs=0:1 --mirrored-log --measure-latency=0  --rate=%d --rate-unit=mpps --size=64 --runtime=120 --runtime-tolerance=5 --run-bidirec=1 --run-revunidirec=0 --num-flows=1024 --src-macs=24:6e:96:c4:0e:88,24:6e:96:c4:0e:8a --dst-macs=24:6e:96:c4:0e:8a,24:6e:96:c4:2f:ea --use-src-ip-flows=1 --use-dst-ip-flows=0 --use-src-mac-flows=0 --use-dst-mac-flows=0 --use-src-port-flows=0 --use-dst-port-flows=0 --use-protocol-flows=0 --packet-protocol=UDP --stream-mode=continuous --max-loss-pct=0.0001 --skip-hw-flow-stats --teaching-measurement-interval=10.0 --teaching-warmup-packet-rate=1000 --teaching-measurement-packet-rate=1000" %tx_i

        # trial 1
        ret = exec_command(pb_cmd)
        for line in ret.splitlines():
            if line.startswith("PARSABLE RESULT:"):
                (, res_d) = line.split(": ")
                d = json.loads(res_d)
                print "tx_pps %d trial 1 TX %s RX %s" %(tx_i, d["total"]["opackets"], d["total"]["ipackets"])
        
        # trial 2
        
        # trial 3
    sys.exit(0)


if __name__ == "__main__":
    main()
