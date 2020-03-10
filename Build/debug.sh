#!/bin/bash

ant;

cp ./build/apache-cassandra-3.11.6-SNAPSHOT.jar /usr/share/cassandra/apache-cassandra-3.11.6.jar;
cp ./build/apache-cassandra-thrift-3.11.6-SNAPSHOT.jar /usr/share/cassandra/apache-cassandra-thrift-3.11.6.jar;

rm -rf /usr/share/cassandra/lib;
cp -r ./lib /usr/share/cassandra;

service cassandra restart;
