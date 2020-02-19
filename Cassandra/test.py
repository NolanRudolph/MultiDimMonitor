# Setup for Cassandra in Multi-Dimensional Monitor

from cassandra.cluster import Cluster

def main():

    cluster = Cluster(['192.168.1.2'])

    session = cluster.connect("synch_keys")

    # Print entries of table
    rows = session.execute("SELECT * FROM main")
    for row in rows:
        print row.key, row.value

    return 0

if __name__ == "__main__":
    main()

