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
    cluster = Cluster(["192.168.1.1", "192.168.1.2", "192.168.2.1", "192.168.2.2", \
                       "192.168.3.1", "192.168.3.2", "192.168.4.1", "192.168.4.2"])
    
    session = cluster.connect("nodes")


    return

if __name__ == "__main__":
    main()
