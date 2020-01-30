#!/bin/bash
# Installs Apache Cassandra to /etc/cassandra
# Log files: /var/log/cassandra/ and /var/lib/cassandra
# Startup Opts: /etc/default/cassandra
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list;
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -;
sudo apt-get update;
sudo apt-get install cassandra;
# Replace existing cassandra.yaml with pre-configured YAML file
cat cassandra.yaml > /etc/cassandra/cassandra.yaml
# If all goes well, the following command should not return an error
nodetool status;
