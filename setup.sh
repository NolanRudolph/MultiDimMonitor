#!/bin/bash
# Installs Apache Cassandra to /etc/cassandra
# Log files: /var/log/cassandra/ and /var/lib/cassandra
# Startup Opts: /etc/default/cassandra

# Update user's system
sudo apt-get update > /dev/null;

# Include Apache Cassandra as a aprt of source list
# COMMENT ME OUT IF NOT DEBIAN -- Instad follow http://cassandra.apache.org/download/
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" >> /etc/apt/sources.list.d/cassandra.sources.list;

# Install wget if not already installed
if [ -z $(which wget) ]
then
	echo "Installing wget...";
	sudo apt-get install -y wget > /dev/null;
fi

# Add key
echo "Adding Apache Cassandra to known keys via curl..."
echo "IF THIS TAKES MORE THAN TEN SECONDS, RESTART THIS SCRIPT"
wget --no-check-certificate -qO - https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -;

# Update system to not ruin user's computer
sudo apt update > /dev/null;

# Install cassandra if not already installed
if [ -z $(which cassandra) ]
then
    echo "Installing cassandra...";
    sudo apt-get install -y cassandra > /dev/null;
fi

# Replace existing cassandra files with pre-configured YAML files
cat ./Cassandra/cassandra.yaml > /etc/cassandra/cassandra.yaml;
cat ./Cassandra/cassandra-env.sh > /etc/cassandra/cassandra-env.sh;

# If all goes well, the following command should not return an error: "nodetool status"
# If this returns error "Cassandra Failed to connect to '127.0.0.1:7199' Connection refused."
# then try changing JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=127.0.0.1" in /etc/cassandra/default.conf/cassandra-env.sh
# to JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=<public name>" where <public name> is the address you want to connect to

# Install maven if not already installed
if [ -z $(which mvn) ]
then
    echo "Installing maven...";
    sudo apt-get install -y maven > /dev/null;
fi

# Install pip if not already installed
if [ -z $(which pip) ]
then
    echo "Installing pip...";
    sudo apt-get install -y python-pip > /dev/null;
fi

# Install Java if not already installed
if [ -z $(which java) ]
then
    echo "Installing Java...";
    sudo add-apt-repository ppa:webupd8team/java > /dev/null;
    sudo apt-get -y install oracle-java8-installer > /dev/null;
    sudo apt-get -y install oracle-java8-set-default > /dev/null;
fi

# Install JDK 8 if not already installed
if [ -z $(java -version 2>&1 | grep "openjdk version \"1.8.0_242\"") ]
then
    echo "Installing JDK 8...";
    sudo apt-get install -y openjdk-8-jdk > /dev/null;
fi

echo "Finished Setup."
