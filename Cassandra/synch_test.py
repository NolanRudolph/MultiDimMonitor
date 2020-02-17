# Setup for Cassandra in Multi-Dimensional Monitor

import sys
from cassandra.cluster import Cluster

def main():
    if len(sys.argv) != 2:
        print("Usage: $ python synch_test.py <IP Addr>")
        return 1

    cluster = Cluster([sys.argv[1]])

    session = cluster.connect("synch_keys")

    # Print entries of table
    rows = session.execute("SELECT * FROM main")
    for row in rows:
        print row.key, row.value

    return 0

if __name__ == "__main__":
    main()
