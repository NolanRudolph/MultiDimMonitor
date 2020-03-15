#!/bin/bash
# If you find yourself with a royally screwed up Cassandra, run this script

# Start in Correct Directory
cd ~/MultiDimMonitor;

# Remove the screwed up Cassandra
printf "Removing Cassandra...\n\n";
sudo apt-get -y remove cassandra > /dev/null;

# Reinstall Cassandra
printf "Installing Cassandra...\n\n";
sudo apt-get -y install cassandra > /dev/null;

# Rebuild your edits to DynamicEndpointSnitch.java
printf "Recompiling Cassandra...\n";
printf "Make sure it finishes with \"BUILD SUCCESSFUL\"\n\n";
cd Build;
bash setup.sh;

# Ensure that cassandra.yaml is equal to yours
printf "Ensuring Consistency of cassandra.yaml and cassandra-env.sh...\n\n";
cd ../Cassandra;
DIFF_YAML=$(diff cassandra.yaml /etc/cassandra/cassandra.yaml);
DIFF_BASH=$(diff cassandra-env.sh /etc/cassandra/cassandra-env.sh);
if  [[ $DIFF_YAML != "" ]] || [[ $DIFF_BASH != "" ]]
then
    sudo cp cassandra.yaml /etc/cassandra/cassandra.yaml;
fi

# Restart Cassandra
printf "Restarting Cassandra...\n\n";
sudo service cassandra restart;

echo "Finished!";
