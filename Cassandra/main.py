# Setup for Cassandra in Multi-Dimensional Monitor

from cassandra.cluster import Cluster

def main():
    # Create a cluster with local host as the solo IP
    # 192.168.1.0: Client    (Makes request)
    # 192.168.1.1: Server    (Receives requests)
    # 192.168.1.2: Replica 1 (Holds database @ Wiscounsin)
    # 192.168.1.3: Replica 2 (Holds database @ Wiscounsin)
    # 192.168.1.4: Replica 3 (Holds database @ Clemson)
    # 192.168.1.5: Replica 4 (Holds database @ Clemson)
    cluster = Cluster(['192.168.1.0', '192.168.1.1', '192.168.1.2', \
                       '192.168.1.3', '192.168.1.4', '192.168.1.5'])
    session = cluster.connect()

    # Create Keyspace on all nodes
    session.execute("CREATE KEYSPACE synch_keys IF NOT EXISTS synch_keys")
    # Switch to this keyspace
    session.execute("USE synch_keys")
    # Create Table in new keyspace
    session.execute("CREATE TABLE main (key text, value text) IF NOT EXISTS main")
    # Add some entries
    session.execute("INSERT INTO main (key, value) VALUES (test1, result1)")
    session.execute("INSERT INTO main (key, value) VALUES (test2, result2)")
    session.execute("INSERT INTO main (key, value) VALUES (test3, result3)")

    return 0

if __name__ == "__main__":
    main()
