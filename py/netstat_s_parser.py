#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt
import re

# USER SECTION BEGIN
file = "netstat_s.out"
filters = (
	   r'(\d+) (active connections openings)',
	   r'(\d+) (passive connection openings)',
	   r'(\d+) (connections established)',

	   r'(\d+) (TCP sockets finished time wait in fast timer)',
	   r'(\d+) (times recovered from packet loss by selective acknowledgements)',
	   r'(\d+) (fast retransmits)',
	   #r'(TCPDSACKIgnoredNoUndo:) (\d+)',
	   #r'(TCPSackShiftFallback:) (\d+)',
	  )
# USER SECTION END

with open(file) as f:
	data = f.read()
	f.close()

dataset = re.split('Thu Nov .* 2017', data)
dataset.pop(0)

res = [None] * len(filters)
t = np.arange(0., len(dataset) * 2., 2.)
for filter in filters:
	res[filters.index(filter)] = []
	for set in dataset:
		m = re.search(filter, set)
		res[filters.index(filter)].append(int(m.group(1)))
	plt.plot(t, res[filters.index(filter)], label="%s" %m.group(2)) 

plt.legend(loc='upper left')
plt.show()
