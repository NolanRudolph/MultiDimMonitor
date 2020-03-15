cd dist_storage
sudo bash ./stop_cassandra.sh
str="$*"
sudo bash "./copy_cassandra_$str.sh"
sudo bash ./start_cassandra.sh
sleep 120
nodetool status
