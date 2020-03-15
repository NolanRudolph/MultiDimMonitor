#!/bin/bash

# Used to end Cassandra procecess
STOP() {
    sudo service cassandra stop;
}

INSTALL_YCSB() {
    printf "\n\n***** INSTALLING YCSB *****\n\n";
    cd $CODE
    if ! [ -d "mapkeeper" ]; then
        git clone https://gitlab.com/sudarsunkannan/mapkeeper
    fi
	cp $CODE/xml/thrift/build.properties $CODE/mapkeeper/thrift-0.8.0/lib/java/build.properties	
    cd $CODE/mapkeeper/ycsb/YCSB
    mvn clean package;
}

# Used in conjunction with my prebuilt Cassandra @MultiDimMonitor/Build
INSTALL_CASSANDRA_SOURCE(){
    printf "\n\n***** INSTALLING CASSANDRA SOURCE *****\n\n";
    cd $CODE

    if ! [ -d "apache-ant-1.10.0" ]; then
        INSTALL_ANT
    fi	

    cp $CODE/xml/libraries.properties $CODE/apache-ant-1.10.0/lib/libraries.properties	

    cp -r ~/MultiDimMonitor/Build ./cassandra
    # cp $CODE/xml/*.xml $CODE/cassandra/
    # cp $CODE/xml/build.properties.default $CODE/cassandra/

    #Step 2: Replace x86 specific jar files
    echo "Replcaing x86 specific jar files..."
    cd $CSRC 
    rm $CSRC/lib/snappy-java-1.1.1.7.jar
    wget -O lib/snappy-java-1.1.2.6.jar https://repo1.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.2.6/snappy-java-1.1.2.6.jar > /dev/null;

    #Build and replace JNA
    echo "Building and replacing JNA..."
    git clone https://github.com/java-native-access/jna.git > /dev/null;
    cd jna
    git checkout 4.2.2 > /dev/null
    echo "Building XML..."
    ant

    rm $CSRC/lib/jna-4.2.2.jar
    cp $CSRC/jna/build/jna.jar $CSRC/lib/jna-4.2.2.jar

    # Not sure what this does but might be important
    gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
    gpg --export --armor F758CE318D77295D | sudo apt-key add -

    gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
    gpg --export --armor 2B5C1B00 | sudo apt-key add -

    gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
    gpg --export --armor 0353B12C | sudo apt-key add -

    echo "Updating user's machine..."
    sudo apt-get update > /dev/null
    RUN_YCSB_CASSANDRA

    cp $CODE/cassandra.sh $CSRC/bin/
}

INSTALL_ANT() 
{
    printf "\n\n***** INSTALLING MAVEN/ANT *****\n\n";
    cd $CODE
    sudo apt-get update
    sudo apt-get install -y git tar g++ make automake autoconf libtool  wget patch libx11-dev libxt-dev pkg-config texinfo locales-all unzip python
    sudo apt-get install -y maven

    # Install Apache Ant if not already installed
    if ! [[ -f "apache-ant-1.10.0-bin.tar.gz" ]]
    then
        echo "Retrieving apache-ant-1.10.0...";
        wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.10.0-bin.tar.gz > /dev/null;
        tar -xvf apache-ant-1.10.0-bin.tar.gz > /dev/null;
    fi
}

RUN_YCSB_CASSANDRA() 
{
    printf "\n\n***** RUNNING YCSB CASSANDRA *****\n\n";
    # Essentially starting cassandra
    cd $YCSBHOME/cassandra
    bash start_service.sh 
}

INSTALL_SYSTEM_LIBS()
{
    sudo apt-get install -y git
    #git commit --amend --reset-author

    sudo apt-get install -y software-properties-common
    sudo apt-get install -y python3-software-properties
    sudo apt-get install -y python-software-properties
    sudo apt-get install -y unzip
    sudo apt-get install -y python-setuptools python-dev build-essential
    sudo easy_install pip
    sudo apt-get install -y numactl
    sudo apt-get install -y libsqlite3-dev
    sudo apt-get install -y libnuma-dev
    sudo apt-get install -y libkrb5-dev
    sudo apt-get install -y libsasl2-dev
    sudo apt-get install -y cmake
    sudo apt-get install -y build-essential
    sudo apt-get install -y maven
    sudo apt-get install -y fio
    sudo apt-get install -y libbfio-dev
    sudo apt-get install -y libboost-dev
    sudo apt-get install -y libboost-thread-dev
    sudo apt-get install -y libboost-system-dev
    sudo apt-get install -y libboost-program-options-dev
    sudo apt-get install -y libconfig-dev
    sudo apt-get install -y uthash-dev
    sudo apt-get install -y libmpich2-dev
    sudo apt-get install -y libglib2.0-dev
    sudo apt-get install -y cscope
    sudo apt-get install -y msr-tools
    sudo apt-get install -y msrtool
    sudo apt-get install -y textinfo
    sudo apt-get install -y dpkg
    sudo pip install psutil
}

STOP
cd $CODE
# fuser -k $PORT/tcp
# Uncomment the following line if its first time
# INSTALL_SYSTEM_LIBS
INSTALL_CASSANDRA_SOURCE
INSTALL_YCSB
