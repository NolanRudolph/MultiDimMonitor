#!/bin/bash

# Run build.xml with preconfigured objectives
sudo cp -r ./.m2 /root/
sudo ant;

# Recompile Cassandra with existing edits
sudo cp ./build/apache-cassandra-3.11.6-SNAPSHOT.jar /usr/share/cassandra/apache-cassandra-3.11.6.jar;
sudo cp ./build/apache-cassandra-thrift-3.11.6-SNAPSHOT.jar /usr/share/cassandra/apache-cassandra-thrift-3.11.6.jar;

# Replace the existing Cassandra lib with the newly compiled one
sudo rm -rf /usr/share/cassandra/lib;
sudo cp -r ./lib /usr/share/cassandra;

# Configuration file to be read by DynamicEndpointSnitch.java
sudo cp ./cassandra_config.txt /cassandra_config.txt

# Restart Cassandra
sudo service cassandra restart;

echo "Setup Completed.";
