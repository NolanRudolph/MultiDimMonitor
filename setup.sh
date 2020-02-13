#!/bin/bash
# Installs Apache Cassandra to /etc/cassandra
# Log files: /var/log/cassandra/ and /var/lib/cassandra
# Startup Opts: /etc/default/cassandra

# Include Apache Cassandra as a aprt of source list
# COMMENT ME OUT IF NOT DEBIAN -- Instad follow http://cassandra.apache.org/download/
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list;

# Add key
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -;

# Update system to not ruin user's computer
sudo apt update;

# Install cassandra if not already installed
if [ -z (which cassandra) ]
then
    echo "Installing cassandra...";
    sudo apt install cassandra;
fi

# Replace existing cassandra files with pre-configured YAML files
cat ./Cassandra/cassandra.yaml > /etc/cassandra/cassandra.yaml;
cat ./Cassandra/cassandra-env.yaml > /etc/cassandra/cassandra-env.yaml;

# If all goes well, the following command should not return an error
nodetool status;
# If this returns error "Cassandra Failed to connect to '127.0.0.1:7199' Connection refused."
# then try changing JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=127.0.0.1" in /etc/cassandra/default.conf/cassandra-env.sh
# to JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=<public name>" where <public name> is the address you want to connect to

# Install pip if not already installed
if [ -z $(which pip) ]
then
    echo "Installing pip...";
    sudo apt install pip;
fi

# Install cassandra-driver if not already installed
if [ -z $(which cassandra-driver) ]
then
    echo "Installing cassandra-driver...";
    sudo apt install cassandra-driver;
fi

echo "Finished Setup."
