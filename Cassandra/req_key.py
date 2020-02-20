#!/usr/bin/python
# Setup for Cassandra in Multi-Dimensional Monitor
#
# NOTE: This should ONLY be used with Client and Server running
# Otherwise, best_ip.txt and req_key.txt will not exist

import sys
from cassandra.cluster import Cluster

def get_value(ip, key):
    cluster = Cluster([ip])
    session = cluster.connect("synch_keys")
    req = "SELECT * FROM main WHERE key=\'" + key + '\''
    val = session.execute(req)

    return val

# Get IP of best node
f = open("best_node.txt", "r")
best_ip = f.read().strip()
f.close()

# Get Requested Key
f = open("req_key.txt", "r")
req_key = f.read().strip()
f.close()

# Write the respective value to "ret_val.txt"
f = open("ret_val.txt", "w+")
ret = get_value(best_ip, req_key)
for row in ret:
    f.write(row.value + '\n')
f.close()
