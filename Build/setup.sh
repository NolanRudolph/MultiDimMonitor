#!/bin/bash

sudo cp -r ./.m2 /root/
sudo ant;

sudo cp ./build/apache-cassandra-3.11.6-SNAPSHOT.jar /usr/share/cassandra/apache-cassandra-3.11.6.jar;
sudo cp ./build/apache-cassandra-thrift-3.11.6-SNAPSHOT.jar /usr/share/cassandra/apache-cassandra-thrift-3.11.6.jar;

sudo rm -rf /usr/share/cassandra/lib;
sudo cp -r ./lib /usr/share/cassandra;

sudo service cassandra restart;

echo "Setup Succesful!";
