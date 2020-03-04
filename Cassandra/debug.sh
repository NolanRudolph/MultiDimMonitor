#!/bin/bash

mvn clean install;

cp target/CustomSnitch-1.jar /usr/share/cassandra/lib/;

service cassandra restart;

tail -f /var/log/cassandra/system.log;
