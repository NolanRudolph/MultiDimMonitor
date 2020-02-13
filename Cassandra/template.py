# Setup for Cassandra in Multi-Dimensional Monitor

from cassandra.cluster import Cluster

def main():
    # Create a cluster with local host as the solo IP
    cluster = Cluster(["127.0.0.1"])
    session = cluster.connect("test_keyspace")

    # Print entries of table
    rows = session.execute("SELECT * FROM python_table")
    for row in rows:
        print row.id, row.name

    return 0

if __name__ == "__main__":
    main()
