#!/bin/bash
if [ $1 -ge 0 ]
then
        sleep $1
	ovs-vsctl set Interface dpdk0 other_config:pmd-rxq-affinity="0:16" \
		-- set Interface dpdkvhostclient1 other_config:pmd-rxq-affinity="0:16" \
		-- set Interface dpdk1 other_config:pmd-rxq-affinity="0:40" \
		-- set Interface dpdkvhostclient0 other_config:pmd-rxq-affinity="0:40"
else
	ovs-vsctl set Interface dpdk0 other_config:pmd-rxq-affinity="0:40" \
		-- set Interface dpdkvhostclient1 other_config:pmd-rxq-affinity="0:40" \
		-- set Interface dpdk1 other_config:pmd-rxq-affinity="0:16" \
		-- set Interface dpdkvhostclient0 other_config:pmd-rxq-affinity="0:16"

fi
