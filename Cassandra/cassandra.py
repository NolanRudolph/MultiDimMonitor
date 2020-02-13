# Setup for Cassandra in Multi-Dimensional Monitor

from cassandra.cluster import Cluster

# _._.1.1: Server-Side IP to Client
# _._.1.2: Client-Side IP to Server
# _._.2.1: Server-Side IP to Replica 1
# _._.2.2: Replica1-Side IP to Server
# _._.3.1: Server-Side IP to Replica 2
# _._.3.2: Replica2-Side IP to Server
# _._.4.1: Server-Side IP to Replica 3
# _._.4.2: Replica3-Side IP to Server

def main():          
    cluster = Cluster()

    session = cluster.connect("test_keyspace")

    # cluster = cluster(["192.168.1.1", "192.168.1.2", "192.168.2.1", "192.168.2.2", \
    #                   "192.168.3.1", "192.168.3.2", "192.168.4.1", "192.168.4.2"])
    
    for row in rows:
        print row.first_name, row.last_name

    return 0

if __name__ == "__cassandra__":
    main()
