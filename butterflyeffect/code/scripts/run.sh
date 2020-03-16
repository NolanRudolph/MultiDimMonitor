#!/bin/bash
set -x
YCSB_CLIENT=$CODE/mapkeeper/ycsb/YCSB
OPSCNT=500000

#Note. for remote host, make the changes in
#/etc/cassandra.yaml for the server to listen 
#on its ip.

DESTROY() {
    sudo service cassandra stop
    sleep 5
}

RUN_CASSANDARA() {
    cd $CSRC

    #Delete data folder
    mkdir $SHARED_DATA
    #rm -rf $SHARED_DATA/*
    rm -rf $CSRC/data
    rm -rf $CSRC/data/data
    unlink $CSRC/data
    unlink $SHARED_DATA
    mkdir -p $CSRC/data/data

    # Removed for now
    #$CSRC/bin/cassandra
    echo "Beginning Cassandra..."
    sudo service cassandra start
    sleep 20
}

RUN_YCSB() {

	cd $YCSBHOME

	#Execute these commands to create ycsb keyspace with cassandra db
	cqlsh 192.168.1.1 -e "create keyspace ycsb WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor': 1 }; USE ycsb; create table usertable (y_id varchar primary key, field0 varchar, field1 varchar, field2 varchar,field3 varchar,field4 varchar, field5 varchar, field6 varchar,field7 varchar,field8 varchar,field9 varchar);" #> ~/output

	#wait
	sleep 5
	#Warm up phase. Load the db
	$YCSBHOME/bin/ycsb load cassandra2-cql -p hosts=192.168.1.1 -p port=$PORT -p recordcount=$OPSCNT -P $YCSBHOME/workloads/workloada -s
	#Wait
	sleep 5
	#Run phase
    # **Modified**
	$YCSBHOME/bin/ycsb run cassandra2-cql -p hosts=192.168.1.1 -p port=$PORT -p recordcount=$OPSCNT -P $YCSBHOME/workloads/workloada 

	sudo service cassandra stop
}

cd $CODE
DESTROY
# Run Cassandra and YCSB
RUN_CASSANDARA
RUN_YCSB
DESTROY
